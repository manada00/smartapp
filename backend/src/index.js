const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: '.environment' });
dotenv.config({ path: path.resolve(__dirname, '../.environment'), override: false });
dotenv.config({ path: path.resolve(__dirname, '../.env'), override: false });
dotenv.config();
const kashierEnvPath = path.resolve(__dirname, '../kashair.env');
if (fs.existsSync(kashierEnvPath)) {
  dotenv.config({ path: kashierEnvPath, override: false });

  const rawKashierEnv = fs.readFileSync(kashierEnvPath, 'utf8');
  rawKashierEnv
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('#') && line.includes('='))
    .forEach((line) => {
      const index = line.indexOf('=');
      const rawKey = line.slice(0, index).trim();
      const rawValue = line.slice(index + 1).trim();

      if (!rawKey || process.env[rawKey]) {
        return;
      }

      process.env[rawKey] = rawValue;
      process.env[rawKey.replace(/\s+/g, '_').toUpperCase()] = rawValue;
      process.env[rawKey.replace(/\s+/g, '-')] = rawValue;
    });
}
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const http = require('http');
const { Server } = require('socket.io');
const connectDB = require('./config/database');
const User = require('./models/User');

// Routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const foodRoutes = require('./routes/food');
const orderRoutes = require('./routes/orders');
const subscriptionRoutes = require('./routes/subscriptions');
const webhookRoutes = require('./routes/webhooks');
const adminAuthRoutes = require('./routes/adminAuth');
const adminRoutes = require('./routes/admin');

const allowedOrigins = Array.from(new Set([
  'https://smartapp-7jsj.vercel.app',
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  ...(process.env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
]));

const isAllowedOrigin = (origin) => {
  if (!origin) return true;
  return allowedOrigins.includes(origin);
};

const corsOptions = {
  origin(origin, callback) {
    if (isAllowedOrigin(origin)) {
      return callback(null, true);
    }
    return callback(new Error(`CORS blocked for origin: ${origin}`));
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ['GET', 'POST'],
  },
});

// Connect to database
connectDB().catch((error) => {
  console.error(`Initial database connection failed: ${error.message}`);
});

// Middleware
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(morgan('dev'));
app.use(express.json());

app.use(async (req, res, next) => {
  try {
    await connectDB();
    return next();
  } catch (error) {
    console.error(`Database connection failed: ${error.message}`);
    return res.status(503).json({
      success: false,
      message: 'Database connection unavailable',
    });
  }
});

// Make io accessible to routes
app.set('io', io);

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/food', foodRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/subscriptions', subscriptionRoutes);
app.use('/api/v1/webhooks', webhookRoutes);
app.use('/api/webhooks', webhookRoutes);
app.use('/api/v1/admin/auth', adminAuthRoutes);
app.use('/api/v1/admin', adminRoutes);

// Alias routes for future provider integrations
app.use('/auth', authRoutes);
app.use('/user', userRoutes);
app.use('/food', foodRoutes);
app.use('/orders', orderRoutes);
app.use('/subscriptions', subscriptionRoutes);
app.use('/webhooks', webhookRoutes);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'SmartApp API running' });
});

app.get('/db-test', async (req, res) => {
  try {
    const users = await User.find().limit(1);

    res.status(200).json({
      success: true,
      count: users.length,
      message: 'MongoDB connected successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Socket.IO connection
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Join room for order tracking
  socket.on('trackOrder', (orderId) => {
    socket.join(`order:${orderId}`);
    console.log(`Socket ${socket.id} joined order:${orderId}`);
  });

  // Leave order tracking room
  socket.on('stopTrackingOrder', (orderId) => {
    socket.leave(`order:${orderId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Function to emit order updates
const emitOrderUpdate = (orderId, data) => {
  io.to(`order:${orderId}`).emit('orderUpdate', data);
};

// Export for use in routes
app.set('emitOrderUpdate', emitOrderUpdate);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

if (process.env.NODE_ENV !== 'production' && !process.env.VERCEL) {
  const PORT = process.env.PORT || 3000;
  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;
