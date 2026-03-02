const EGYPT_LOCAL_PATTERN = /^(10|11|12|15)\d{8}$/;

const normalizeEgyptPhoneToE164 = (value) => {
  const raw = String(value || '').trim();
  if (!raw) {
    throw new Error('phoneNumber is required');
  }

  const digitsOnly = raw.replace(/\D/g, '');

  let local = '';
  if (digitsOnly.startsWith('20') && digitsOnly.length === 12) {
    local = digitsOnly.slice(2);
  } else if (digitsOnly.startsWith('0') && digitsOnly.length === 11) {
    local = digitsOnly.slice(1);
  } else if (digitsOnly.length === 10) {
    local = digitsOnly;
  } else {
    throw new Error('Invalid Egyptian phone number format');
  }

  if (!EGYPT_LOCAL_PATTERN.test(local)) {
    throw new Error('Invalid Egyptian phone number format');
  }

  return `+20${local}`;
};

module.exports = {
  normalizeEgyptPhoneToE164,
};
