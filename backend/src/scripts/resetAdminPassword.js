require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const AdminUser = require('../models/AdminUser');

async function resetAdminPassword() {
  const { MONGODB_URI, ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;

  if (!MONGODB_URI) {
    throw new Error('MONGODB_URI is required');
  }

  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required');
  }

  await mongoose.connect(MONGODB_URI);

  const email = ADMIN_EMAIL.toLowerCase().trim();
  const admin = await AdminUser.findOne({ email });

  if (!admin) {
    throw new Error(`Admin user not found for ${email}`);
  }

  admin.passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);
  await admin.save();

  console.log(`Password updated for ${email}.`);
}

resetAdminPassword()
  .catch((error) => {
    console.error('Failed to reset admin password:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.connection.close();
  });
