const { createMockPaymentGateway } = require('./mockPaymentGateway');

class PaymentService {
  constructor({ gateway } = {}) {
    this.gateway = gateway || createMockPaymentGateway();
  }

  processInitialPayment({ paymentMethod }) {
    return this.gateway.simulateInitialPayment({ paymentMethod });
  }

  verifyInstapayTransfer() {
    return this.gateway.verifyInstapayTransfer();
  }
}

module.exports = {
  PaymentService,
};
