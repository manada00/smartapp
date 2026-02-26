require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const AdminUser = require('../models/AdminUser');

async function createAdmin() {
  const { MONGODB_URI, ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_ROLE } = process.env;

  if (!MONGODB_URI) {
    throw new Error('MONGODB_URI is required');
  }

  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required');
  }

  const normalizedRole = (ADMIN_ROLE || 'SUPER_ADMIN').toUpperCase();
  const role = normalizedRole === 'ADMIN' ? 'SUPER_ADMIN' : normalizedRole;

  if (!['SUPER_ADMIN', 'OPERATIONS_ADMIN', 'SUPPORT_ADMIN'].includes(role)) {
    throw new Error('ADMIN_ROLE must be one of SUPER_ADMIN, OPERATIONS_ADMIN, SUPPORT_ADMIN');
  }

  await mongoose.connect(MONGODB_URI);

  const email = ADMIN_EMAIL.toLowerCase().trim();
  const existingAdmin = await AdminUser.findOne({ email });

  if (existingAdmin) {
    console.log(`Admin already exists for ${email}. Skipping creation.`);
    return;
  }

  const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);

  await AdminUser.create({
    email,
    passwordHash,
    role,
    isActive: true,
  });

  console.log(`Admin user created for ${email} with role ${role}.`);
}

createAdmin()
  .catch((error) => {
    console.error('Failed to create admin:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await mongoose.connection.close();
  });
