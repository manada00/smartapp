# smartApp Admin Console - Run Guide

## 1) Prerequisites

- Node.js **20+** (recommended)
- npm **10+**

## 2) Local Setup

```bash
cd "/Users/mohab.nada/Cursor Ai/NoreApp/admin-console"
cp .env.example .env.local
```

Set these values in `.env.local`:

- `BACKEND_API_URL` (example: `http://localhost:4000`)

Set these values in `backend/.env` so admin login works:

- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `ADMIN_ROLE` (`SUPER_ADMIN` / `OPERATIONS_ADMIN` / `SUPPORT_ADMIN`)

Start backend first:

```bash
cd "/Users/mohab.nada/Cursor Ai/NoreApp/backend"
npm install
# set PORT=4000 in backend/.env to avoid clashing with Next.js port 3000
npm run dev
```

Install and run:

```bash
npm install
npm run dev
```

Open: `http://localhost:3000`

Login with your `ADMIN_EMAIL` / `ADMIN_PASSWORD`.

## 3) Production Mode (Local)

```bash
npm run build
npm run start
```

## 4) Run on Different Platforms

### macOS / Linux

```bash
cd "/Users/mohab.nada/Cursor Ai/NoreApp/admin-console"
npm install
npm run dev
```

### Windows (PowerShell)

```powershell
cd "C:\Users\<your-user>\Cursor Ai\NoreApp\admin-console"
copy .env.example .env.local
npm install
npm run dev
```

## 5) Validation Commands

```bash
npm run lint
npm run typecheck
npm run build
```
