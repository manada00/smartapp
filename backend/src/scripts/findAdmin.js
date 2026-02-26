require('dotenv').config();
const mongoose = require('mongoose');
const AdminUser = require('../models/AdminUser');

async function findAdmin() {
  const { MONGODB_URI } = process.env;

  if (!MONGODB_URI) {
    throw new Error('MONGODB_URI is required');
  }

  await mongoose.connect(MONGODB_URI);

  const admins = await AdminUser.find({ role: 'SUPER_ADMIN' })
    .select('email role createdAt -_id')
    .sort({ createdAt: 1 })
    .lean();

  if (!admins.length) {
    console.log('No SUPER_ADMIN user found.');
    return;
  }

  console.table(
    admins.map((admin) => ({
      email: admin.email,
      role: admin.role,
      createdAt: admin.createdAt,
    })),
  );
}

findAdmin()
  .catch((error) => {
    console.error('Failed to find admin:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.connection.close();
  });
