const PAYMENT_METHODS = {
  COD: 'cod',
  CARD: 'card',
  INSTAPAY: 'instapay',
};

const PAYMENT_STATUSES = {
  PENDING: 'pending',
  PAID: 'paid',
  FAILED: 'failed',
  AWAITING_TRANSFER: 'awaiting_transfer',
};

const ORDER_STATUSES = {
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
};

const randomId = (prefix) => `${prefix}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;

const weightedChoice = (entries) => {
  const roll = Math.random();
  let cumulative = 0;

  for (const [value, weight] of entries) {
    cumulative += weight;
    if (roll <= cumulative) return value;
  }

  return entries[entries.length - 1][0];
};

const createMockPaymentGateway = () => ({
  simulateInitialPayment({ paymentMethod }) {
    if (paymentMethod === PAYMENT_METHODS.COD) {
      return {
        paymentStatus: PAYMENT_STATUSES.PENDING,
        orderStatus: ORDER_STATUSES.CONFIRMED,
        transactionId: randomId('COD'),
        message: 'Your order will be paid upon delivery.',
      };
    }

    if (paymentMethod === PAYMENT_METHODS.CARD) {
      const result = weightedChoice([
        ['success', 0.7],
        ['failed', 0.2],
        ['pending', 0.1],
      ]);

      if (result === 'success') {
        return {
          paymentStatus: PAYMENT_STATUSES.PAID,
          orderStatus: ORDER_STATUSES.CONFIRMED,
          transactionId: randomId('CARD'),
          message: 'Payment approved.',
        };
      }

      if (result === 'failed') {
        return {
          paymentStatus: PAYMENT_STATUSES.FAILED,
          orderStatus: ORDER_STATUSES.PENDING,
          transactionId: randomId('CARD'),
          message: 'Payment failed. Please retry.',
        };
      }

      return {
        paymentStatus: PAYMENT_STATUSES.PENDING,
        orderStatus: ORDER_STATUSES.PENDING,
        transactionId: randomId('CARD'),
        message: 'Payment processing...',
      };
    }

    if (paymentMethod === PAYMENT_METHODS.INSTAPAY) {
      return {
        paymentStatus: PAYMENT_STATUSES.AWAITING_TRANSFER,
        orderStatus: ORDER_STATUSES.PENDING,
        transactionId: randomId('INST'),
        referenceCode: randomId('INST'),
        fakeIban: 'EG00MOCK0000001234567890123456',
        message: 'Transfer pending verification.',
      };
    }

    throw new Error('Unsupported payment method');
  },

  verifyInstapayTransfer() {
    const isVerified = Math.random() <= 0.8;

    if (isVerified) {
      return {
        paymentStatus: PAYMENT_STATUSES.PAID,
        orderStatus: ORDER_STATUSES.CONFIRMED,
        message: 'Transfer verified successfully.',
      };
    }

    return {
      paymentStatus: PAYMENT_STATUSES.AWAITING_TRANSFER,
      orderStatus: ORDER_STATUSES.PENDING,
      message: 'Transfer could not be verified yet.',
    };
  },
});

module.exports = {
  createMockPaymentGateway,
  PAYMENT_METHODS,
  PAYMENT_STATUSES,
  ORDER_STATUSES,
};
