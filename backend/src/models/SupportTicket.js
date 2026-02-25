const mongoose = require('mongoose');

const supportMessageSchema = new mongoose.Schema({
  senderType: {
    type: String,
    enum: ['user', 'admin'],
    required: true,
  },
  senderUser: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  senderAdmin: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'AdminUser',
  },
  channel: {
    type: String,
    enum: ['message', 'email'],
    default: 'message',
  },
  content: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, { _id: false });

const supportTicketSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  subject: {
    type: String,
    required: true,
    trim: true,
  },
  status: {
    type: String,
    enum: ['open', 'pending', 'resolved', 'closed'],
    default: 'open',
    index: true,
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium',
  },
  assignedAdmin: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'AdminUser',
  },
  initialChannel: {
    type: String,
    enum: ['message', 'email'],
    default: 'message',
  },
  messages: {
    type: [supportMessageSchema],
    default: [],
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('SupportTicket', supportTicketSchema);
