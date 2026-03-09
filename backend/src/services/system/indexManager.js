const User = require('../../models/User');
const Order = require('../../models/Order');
const Food = require('../../models/Food');
const Category = require('../../models/Category');
const AkedlyAuthSession = require('../../models/AkedlyAuthSession');

let indexSyncPromise = null;

const ensureDatabaseIndexes = async () => {
  if (indexSyncPromise) {
    return indexSyncPromise;
  }

  indexSyncPromise = Promise.all([
    User.syncIndexes(),
    Order.syncIndexes(),
    Food.syncIndexes(),
    Category.syncIndexes(),
    AkedlyAuthSession.syncIndexes(),
  ]).catch((error) => {
    indexSyncPromise = null;
    throw error;
  });

  return indexSyncPromise;
};

module.exports = {
  ensureDatabaseIndexes,
};
