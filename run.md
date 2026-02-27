>  how to run it

⛬  To run the Smart Food app:

   Flutter App (Frontend)

   bash
     # 1. Navigate to project
     cd "/Users/mohab.nada/Cursor Ai/NoreApp"

     # 2. Install dependencies
     flutter pub get

     # 3. Generate model files (required once)
     flutter pub run build_runner build --delete-conflicting-outputs

     # 4. Run the app
     flutter run

   Run on specific device:

   bash
     flutter run -d ios      # iOS Simulator
     flutter run -d android  # Android Emulator
     flutter devices         # List available devices

   Backend (Node.js)

   bash
     # 1. Navigate to backend
     cd "/Users/mohab.nada/Cursor Ai/NoreApp/backend"

     # 2. Install dependencies
     npm install

     # 3. Create .env file with your MongoDB URI and other configs
     # (see README for template)

     # 4. Seed database with sample data
     node src/seeds/seedData.js

     # 5. Start server
     npm run dev

   Requirements
   •  Flutter: 3.32.0+
   •  Node.js: 18.x+
   •  MongoDB: 6.0+ (or MongoDB Atlas)

   =============

   You need to either connect a physical device or start an emulator. Here are your options:

   Option 1: iOS Simulator (Recommended for Mac)

   bash
     # Open iOS Simulator
     open -a Simulator

     # Then run
     flutter run

   Option 2: Android Emulator

   bash
     # List available Android emulators
     flutter emulators

     # Launch an emulator (replace with your emulator name)
     flutter emulators --launch <emulator_id>

     # Then run
     flutter run

   Option 3: Enable macOS/Web Support

   If you want to run on macOS or Chrome for testing:

   bash
     # Enable desktop/web support
     flutter create .

     # Run on macOS
     flutter run -d macos

     # Run on Chrome
     flutter run -d chrome

   Option 4: Connect Physical Device

   •  iPhone: Connect via USB, trust the computer, then flutter run
   •  Android: Enable USB debugging in Developer Options, connect via USB, then flutter run

   Which option would you like to use?
   ===================
   OPen the backend:  npm --prefix "/Users/mohab.nada/Cursor Ai/NoreApp/backend" run dev
   if there is issue lsof -i :4000  
   then kill -9 

   This backend is the core API layer for the app: it connects to MongoDB, handles auth (Google/phone OTP + JWT), serves food/menu/categories,
    processes orders/users, and powers all admin-console actions (add/edit items, image replace, bulk pricing, reorder, scheduling).
   It also runs Socket.IO for real-time order updates and exposes routes under /api/v1/* plus /health.

   
   OPen the console: npm --prefix "/Users/mohab.nada/Cursor Ai/NoreApp/admin-console" run dev


   Website

      bash
     npm --prefix "/Users/mohab.nada/Cursor Ai/NoreApp/web-storefront" install
     npm --prefix "/Users/mohab.nada/Cursor Ai/NoreApp/web-storefront" run dev
      npm --prefix "/Users/mohab.nada/Cursor Ai/NoreApp/web-storefront" audit fix --force