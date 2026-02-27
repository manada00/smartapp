# SmartApp Website Login Info

## Customer Website Login

- URL: `http://localhost:3001` (or your deployed storefront URL)
- Login page: `/login`
- Method: Phone OTP (same account as mobile app)
- Phone format: Egyptian 10-digit number (example: `1012345678`)
- Dev OTP (when backend runs in development): `123456`

## Admin Console Login

- URL: `http://localhost:3000` (admin-console)
- Login page: `/login`
- Method: Email + Password
- Default bootstrap credentials (from backend env template):
  - Email: `admin@smartapp.com`
  - Password: `change-this-password`
  - Role: `SUPER_ADMIN`

## Notes

- Both website and mobile use the same backend and user accounts.
- Update credentials via backend environment variables (`ADMIN_EMAIL`, `ADMIN_PASSWORD`, `ADMIN_ROLE`) before production.
