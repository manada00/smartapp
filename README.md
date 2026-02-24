# Smart Food - Mobile Application

A cross-platform mobile application for functional nutrition and food ordering, built with Flutter for iOS and Android. Users select how they want their body to feel (energized, full, focused, calm) and receive personalized meal recommendations.

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Requirements](#requirements)
5. [Installation](#installation)
6. [Project Structure](#project-structure)
7. [Architecture](#architecture)
8. [Screens Documentation](#screens-documentation)
9. [State Management](#state-management)
10. [API Documentation](#api-documentation)
11. [Backend Setup](#backend-setup)
12. [Configuration](#configuration)
13. [Localization (Arabic + RTL)](#localization-arabic--rtl)
14. [Testing](#testing)
15. [Troubleshooting](#troubleshooting)

---

## Overview

**Smart Food** is a functional nutrition and food ordering platform designed for the Egyptian market.

- **Core Concept**: Users don't ask "what do I want to eat" - they ask "what do I need my body to feel like"
- **Target Market**: Egypt
- **Languages**: English + Arabic (RTL supported)
- **Currency**: Egyptian Pound (EGP)

---

## Features

| Feature | Description |
|---------|-------------|
| User Onboarding | Health goals and dietary preferences setup |
| Feeling-based Recommendations | "I need energy", "I'm bloated", etc. |
| Functional Food Scoring | Energy, satiety, digestion, sleep scores |
| Food Ordering | Full cart and checkout flow |
| Multiple Payment Methods | COD, cards, mobile wallets, Fawry |
| Real-time Order Tracking | Live driver location |
| Meal Subscriptions | Weekly meal plans |
| Loyalty Program | Points and rewards system |
| User Wallet | In-app payments |
| Referral Program | Invite friends and earn rewards |
| Localization | English/Arabic language switch with RTL layout |

---

## Tech Stack

### Frontend (Flutter)
| Package | Version | Purpose |
|---------|---------|---------|
| Flutter | 3.32.x+ | UI Framework |
| flutter_riverpod | ^2.5.1 | State Management |
| dio | ^5.4.3 | HTTP Client |
| go_router | ^14.2.3 | Navigation |
| hive_flutter | ^1.1.0 | Local Storage |
| flutter_secure_storage | ^9.2.2 | Secure Storage |
| cached_network_image | ^3.3.1 | Image Caching |
| socket_io_client | ^2.0.3 | Real-time Communication |

### Backend (Node.js)
| Package | Version | Purpose |
|---------|---------|---------|
| express | ^4.19.2 | Web Framework |
| mongoose | ^8.4.0 | MongoDB ODM |
| jsonwebtoken | ^9.0.2 | Authentication |
| socket.io | ^4.7.5 | Real-time Events |
| twilio | ^5.0.4 | SMS/OTP |

---

## Requirements

### Development Environment
- **Flutter SDK**: 3.32.0 or higher
- **Dart SDK**: 3.8.0 or higher
- **Node.js**: 18.x or higher
- **npm**: 9.x or higher
- **MongoDB**: 6.0 or higher (or MongoDB Atlas)

### Platform Requirements
| Platform | Minimum Version |
|----------|-----------------|
| iOS | 12.0+ |
| Android | API 21 (Android 5.0)+ |

### IDE Recommendations
- VS Code with Flutter/Dart extensions
- Android Studio with Flutter plugin
- Xcode 14+ (for iOS development)

---

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd NoreApp
```

### 2. Flutter App Setup

```bash
# Install Flutter dependencies
flutter pub get

# Generate localization files from ARB resources
flutter gen-l10n

# Generate model files (required for JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Verify setup
flutter doctor

# Run the app
flutter run
```

### 3. Backend Setup

```bash
cd backend

# Install Node.js dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your configuration (see Configuration section)

# Seed the database with sample data
node src/seeds/seedData.js

# Start development server
npm run dev
```

### 4. Running on Specific Platforms

```bash
# iOS (requires macOS with Xcode)
flutter run -d ios

# Android
flutter run -d android

# Web (for testing only)
flutter run -d chrome

# List available devices
flutter devices
```

---

## Project Structure

```
NoreApp/
├── lib/                          # Flutter source code
│   ├── core/                     # Core utilities and configuration
│   │   ├── constants/            # App constants, colors, text styles
│   │   │   ├── app_constants.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   ├── theme/                # Theme configuration
│   │   │   └── app_theme.dart
│   │   ├── network/              # API client and interceptors
│   │   │   └── dio_client.dart
│   │   ├── storage/              # Local and secure storage
│   │   │   ├── local_storage.dart
│   │   │   └── secure_storage.dart
│   │   ├── localization/         # Localization helpers
│   │   │   └── l10n_extensions.dart
│   │   └── router/               # Navigation routes
│   │       └── app_router.dart
│   │
│   ├── l10n/                     # ARB files + generated localizations
│   │   ├── app_en.arb
│   │   ├── app_ar.arb
│   │   └── app_localizations.dart
│   │
│   ├── data/                     # Data layer
│   │   └── models/               # Data models (JSON serializable)
│   │       ├── user_model.dart
│   │       ├── food_model.dart
│   │       ├── cart_model.dart
│   │       ├── order_model.dart
│   │       ├── address_model.dart
│   │       ├── subscription_model.dart
│   │       ├── wallet_model.dart
│   │       └── review_model.dart
│   │
│   └── presentation/             # UI layer
│       ├── providers/            # Riverpod state providers
│       │   ├── auth_provider.dart
│       │   ├── cart_provider.dart
│       │   ├── food_provider.dart
│       │   ├── order_provider.dart
│       │   └── address_provider.dart
│       │
│       ├── screens/              # App screens (see Screens Documentation)
│       │   ├── splash/
│       │   ├── onboarding/
│       │   ├── auth/
│       │   ├── profile_setup/
│       │   ├── home/
│       │   ├── recommendations/
│       │   ├── food_detail/
│       │   ├── categories/
│       │   ├── cart/
│       │   ├── checkout/
│       │   ├── orders/
│       │   ├── order_tracking/
│       │   ├── subscriptions/
│       │   ├── profile/
│       │   ├── addresses/
│       │   ├── wallet/
│       │   ├── rewards/
│       │   ├── payments/
│       │   ├── notifications/
│       │   ├── support/
│       │   └── referral/
│       │
│       └── widgets/              # Reusable widgets
│           ├── common/           # Common UI components
│           ├── food/             # Food-related widgets
│           ├── cart/             # Cart widgets
│           └── order/            # Order widgets
│
├── backend/                      # Node.js backend
│   ├── src/
│   │   ├── config/               # Database configuration
│   │   │   └── database.js
│   │   ├── models/               # Mongoose schemas
│   │   │   ├── User.js
│   │   │   ├── Food.js
│   │   │   ├── Category.js
│   │   │   ├── Order.js
│   │   │   └── Address.js
│   │   ├── routes/               # API routes
│   │   │   ├── auth.js
│   │   │   ├── user.js
│   │   │   ├── food.js
│   │   │   └── orders.js
│   │   ├── middleware/           # Express middleware
│   │   │   └── auth.js
│   │   ├── seeds/                # Database seeders
│   │   │   └── seedData.js
│   │   └── index.js              # Server entry point
│   ├── package.json
│   └── .env.example
│
├── assets/                       # Static assets
│   ├── images/
│   ├── icons/
│   └── animations/
│
├── test/                         # Test files
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

---

## Architecture

The app follows a **Clean Architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Screens   │  │   Widgets   │  │   Providers         │ │
│  │   (UI)      │  │  (Reusable) │  │   (State Management)│ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │ Repositories│  │   Data Sources      │ │
│  │  (Entities) │  │  (Abstract) │  │   (API/Local)       │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Constants  │  │   Theme     │  │   Network/Storage   │ │
│  │  & Config   │  │  & Styles   │  │   & Router          │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### State Management Flow (Riverpod)

```
User Action → Provider Notifier → State Update → UI Rebuild
     │              │                  │             │
     └──────────────┴──────────────────┴─────────────┘
                    Reactive Data Flow
```

---

## Screens Documentation

### Authentication Flow

#### 1. Splash Screen (`splash_screen.dart`)
**Path**: `/`

**Purpose**: Initial loading screen that checks authentication state.

**Behavior**:
- Shows app logo with animation
- Checks if user has valid session
- Navigates to appropriate screen based on auth state

**Code Flow**:
```dart
_initApp() → checkAuthState() → Navigate based on:
  - First launch → Onboarding
  - No session → Phone Login
  - Needs setup → Profile Setup
  - Authenticated → Home
```

#### 2. Onboarding Screen (`onboarding_screen.dart`)
**Path**: `/onboarding`

**Purpose**: Introduce app features to new users.

**Components**:
- 3 swipeable slides with illustrations
- Skip button (top right)
- Dot indicators
- Next/Get Started button

#### 3. Phone Login Screen (`phone_login_screen.dart`)
**Path**: `/login`

**Purpose**: User authentication via phone number.

**Features**:
- Egypt country code pre-selected (+20)
- Phone validation (must start with 10, 11, 12, or 15)
- Social login options (Google, Facebook, Apple)
- Terms and Privacy links

**Validation Logic**:
```dart
bool get _isValidPhone {
  final phone = _phoneController.text;
  if (phone.length != 10) return false;
  return ['10', '11', '12', '15'].any((p) => phone.startsWith(p));
}
```

#### 4. OTP Verification Screen (`otp_verification_screen.dart`)
**Path**: `/otp`

**Purpose**: Verify phone number with 6-digit OTP.

**Features**:
- 6 individual input boxes with auto-advance
- Auto-submit on completion
- Resend timer (45 seconds)
- Resend via SMS or WhatsApp

---

### Profile Setup Flow

#### 5. Profile Setup Screen (`profile_setup_screen.dart`)
**Path**: `/setup/profile`

**Purpose**: Basic profile information (Step 1/4).

**Fields**:
- Profile photo (optional)
- Full name (required)
- Email (optional)

#### 6. Health Goals Screen (`health_goals_screen.dart`)
**Path**: `/setup/goals`

**Purpose**: Select health and fitness goals (Step 2/4).

**Available Goals**:
| Goal | Emoji |
|------|-------|
| Lose Weight | 🔥 |
| Build Muscle | 💪 |
| Maintain Weight | ⚖️ |
| Stable Energy | ⚡ |
| Better Digestion | 🫄 |
| Improve Sleep | 😴 |
| Hormonal Balance | 🧬 |
| Gym Performance | 🏋️ |
| Kids Nutrition | 👶 |
| Reduce Cravings | 🍪 |
| Ramadan Fasting | 🌙 |

#### 7. Dietary Preferences Screen (`dietary_preferences_screen.dart`)
**Path**: `/setup/preferences`

**Purpose**: Set dietary restrictions (Step 3/4).

**Sections**:
- Diet Type: Vegetarian, Vegan, Dairy-Free, Gluten-Free, Keto
- Allergies: Multi-select chips + custom input
- Dislikes: Free text input

#### 8. Daily Routine Screen (`daily_routine_screen.dart`)
**Path**: `/setup/routine`

**Purpose**: Configure daily schedule (Step 4/4).

**Settings**:
- Work start/end time
- Training days (Sat-Fri)
- Training time (Morning/Afternoon/Evening)
- Sleep time

---

### Main App Screens

#### 9. Home Screen (`home_screen.dart`)
**Path**: `/home`

**Purpose**: Main dashboard with feeling-based navigation.

**Sections**:
1. **Header**: Greeting, location, notifications, cart
2. **Quick Actions**: Reorder, Favorites, Specials, Subscriptions
3. **Feeling Grid**: 10 feeling buttons (2 columns)
4. **Categories**: Horizontal scrollable cards
5. **Popular Items**: Food cards

**Feeling Types**:
```dart
enum FeelingType {
  needEnergy('I need energy', '⚡'),
  veryHungry("I'm very hungry", '🍽️'),
  somethingLight('Something light', '🥗'),
  trainedToday('I trained today', '💪'),
  stressed("I'm stressed", '😰'),
  bloated("I'm bloated", '🫄'),
  helpSleep('Help me sleep', '😴'),
  kidNeedsMeal('Kid needs meal', '👶'),
  fastingTomorrow('Fasting tomorrow', '🌙'),
  browseAll('Browse all', '🔍'),
}
```

#### 10. Recommendations Screen (`recommendations_screen.dart`)
**Path**: `/recommendations`

**Purpose**: Show personalized meal recommendations based on feeling.

**Categorization**:
- **Perfect for you** (green badge) - Score 4-5
- **Also great** (yellow badge) - Score 3
- **Not ideal right now** (red, collapsible) - Score 1-2

**Filters**: All, High Protein, Low Carb, Under 150 EGP, Quick <15min

#### 11. Food Detail Screen (`food_detail_screen.dart`)
**Path**: `/food/:id`

**Purpose**: Detailed view of a meal with customization options.

**Sections**:
1. Hero image with favorite/share buttons
2. Name, rating, prep time, price
3. Description
4. **Functional Scores** (8 categories with bar charts)
5. "Best For" tags
6. Portion selector
7. Customizations (accordions)
8. Special instructions
9. Sticky bottom: Quantity selector + Add to Cart

**Functional Scores Explained**:
| Score | Description | Good Value |
|-------|-------------|------------|
| Energy Stability | Sustained energy | 4-5 |
| Satiety | How filling | 4-5 |
| Insulin Impact | Blood sugar spike | 1-2 (low is good) |
| Digestion Ease | Gentle on stomach | 4-5 |
| Focus Support | Mental clarity | 4-5 |
| Sleep Friendly | Won't disrupt sleep | 4-5 |
| Kid Friendly | Suitable for children | 4-5 |
| Workout Support | Pre/post workout | 4-5 |

#### 12. Categories Screen (`categories_screen.dart`)
**Path**: `/categories`

**Purpose**: Browse all food categories.

**Display**: 2-column grid with image cards showing category name and item count.

#### 13. Category Detail Screen (`category_detail_screen.dart`)
**Path**: `/category/:id`

**Purpose**: List foods in a specific category with filters.

**Features**:
- Sort by: Recommended, Price, Rating
- Filter modal with: Dietary, Goals, Price Range, Min Rating, Prep Time

---

### Cart & Checkout

#### 14. Cart Screen (`cart_screen.dart`)
**Path**: `/cart`

**Purpose**: Review and modify cart items.

**Sections**:
- Cart items with quantity controls
- Promo code input
- Order summary (subtotal, delivery, discount, total)
- Delivery preview

#### 15. Checkout Screen (`checkout_screen.dart`)
**Path**: `/checkout`

**Purpose**: Complete order with 3-step process.

**Steps**:
1. **Delivery**: Address selection, delivery time
2. **Payment**: Payment method selection
3. **Review**: Final confirmation

**Payment Methods**:
| Method | Description |
|--------|-------------|
| COD | Cash on Delivery (max EGP 2,000) |
| Card | Visa, Mastercard, Meeza via Paymob |
| Mobile Wallet | Vodafone/Orange/Etisalat Cash, WE Pay, CIB |
| Fawry | Pay at kiosk (24hr expiry) |
| InstaPay | Bank transfer |
| Wallet | App wallet balance |

---

### Orders

#### 16. Orders Screen (`orders_screen.dart`)
**Path**: `/orders`

**Purpose**: View order history.

**Tabs**:
- **Active**: Orders in progress with Track button
- **Past**: Completed orders with Reorder/Details/Rate buttons

#### 17. Order Tracking Screen (`order_tracking_screen.dart`)
**Path**: `/tracking/:id`

**Purpose**: Real-time order tracking.

**Features**:
- Live map with driver location (when assigned)
- Status timeline with timestamps
- Driver card with call/WhatsApp buttons
- COD payment reminder
- Collapsible order details

**Order Statuses**:
```
Pending → Confirmed → Preparing → Ready → Out for Delivery → Delivered
                                                          ↓
                                                      Cancelled
```

---

### Subscriptions

#### 18. Subscriptions Screen (`subscriptions_screen.dart`)
**Path**: `/subscriptions`

**Purpose**: Browse meal subscription plans.

**Available Plans**:
| Plan | Price/Week | Meals |
|------|------------|-------|
| Daily Breakfast | EGP 450 | 7 |
| Daily Lunch | EGP 650 | 7 |
| Gym Performance | EGP 550 | 5 |
| Kids Weekly | EGP 400 | 5 |
| Full Day | EGP 1,200 | 21 |

#### 19. Subscription Detail Screen (`subscription_detail_screen.dart`)
**Path**: `/subscription/:id`

**Purpose**: View plan details and subscribe.

**Options**:
- Chef's Choice or Choose Your Meals
- Delivery address
- Delivery time slot

---

### Profile & Settings

#### 20. Profile Screen (`profile_screen.dart`)
**Path**: `/profile`

**Purpose**: User profile and settings hub.

**Menu Sections**:
- Account (Edit Profile, Goals, Preferences, Routine)
- Orders
- Addresses
- Payments
- Rewards
- Settings
- Support
- Legal

#### 21. Edit Profile Screen (`edit_profile_screen.dart`)
**Path**: `/profile/edit`

**Purpose**: Update profile information.

#### 22. Manage Addresses Screen (`manage_addresses_screen.dart`)
**Path**: `/addresses`

**Purpose**: Add, edit, delete delivery addresses.

#### 23. Add Address Screen (`add_address_screen.dart`)
**Path**: `/setup/address`

**Purpose**: Add new delivery address.

**Fields**: Label, Governorate, Area, Street, Building, Floor, Apartment, Landmark

---

### Wallet & Rewards

#### 24. Wallet Screen (`wallet_screen.dart`)
**Path**: `/wallet`

**Purpose**: View balance and transaction history.

**Features**:
- Balance display
- Add Funds button
- Transaction history (credits/debits)

#### 25. Rewards Screen (`rewards_screen.dart`)
**Path**: `/rewards`

**Purpose**: View points, tier status, and available rewards.

**Loyalty Tiers**:
| Tier | Points Required |
|------|-----------------|
| Bronze | 0 |
| Silver | 500 |
| Gold | 1,500 |
| Platinum | 5,000 |

#### 26. Refer Friend Screen (`refer_friend_screen.dart`)
**Path**: `/referral`

**Purpose**: Share referral code with friends.

**Reward**: Give EGP 50, Get EGP 50

---

### Payments & Notifications

#### 27. Payment Methods Screen (`payment_methods_screen.dart`)
**Path**: `/payment-methods`

**Purpose**: Manage saved cards and linked wallets.

#### 28. Notifications Screen (`notifications_screen.dart`)
**Path**: `/notifications`

**Purpose**: View app notifications.

**Types**: Order updates, Promotions, Rewards, Subscriptions

#### 29. Notification Settings Screen (`notification_settings_screen.dart`)
**Path**: `/notifications/settings`

**Purpose**: Configure notification preferences.

---

### Support

#### 30. Help Center Screen (`help_center_screen.dart`)
**Path**: `/help`

**Purpose**: Searchable FAQ with categories.

#### 31. Contact Support Screen (`contact_support_screen.dart`)
**Path**: `/contact`

**Purpose**: Contact options (Chat, Call, Email, WhatsApp).

---

## State Management

### Riverpod Providers

#### AuthProvider (`auth_provider.dart`)
```dart
// Authentication state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>

// States: initial, loading, authenticated, unauthenticated, needsOnboarding, otpSent, error

// User data
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>
```

#### CartProvider (`cart_provider.dart`)
```dart
// Cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartModel>

// Computed values
final cartItemCountProvider = Provider<int>
final cartSubtotalProvider = Provider<double>
final deliveryFeeProvider = Provider<double>
final cartTotalProvider = Provider<double>
```

#### FoodProvider (`food_provider.dart`)
```dart
// Categories
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>

// Foods by category
final foodsProvider = StateNotifierProvider.family<FoodsNotifier, AsyncValue<List<FoodModel>>, String?>

// Single food detail
final foodDetailProvider = FutureProvider.family<FoodModel, String>

// Recommendations
final recommendationsProvider = FutureProvider.family<Map<String, List<FoodModel>>, FeelingType>

// Favorites
final favoriteFoodsProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>
```

#### OrderProvider (`order_provider.dart`)
```dart
// Orders
final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>

// Active/Past orders
final activeOrdersProvider = Provider<List<OrderModel>>
final pastOrdersProvider = Provider<List<OrderModel>>

// Checkout state
final checkoutStateProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>
```

#### AddressProvider (`address_provider.dart`)
```dart
// Addresses
final addressesProvider = StateNotifierProvider<AddressesNotifier, AsyncValue<List<AddressModel>>>

// Default address
final defaultAddressProvider = Provider<AddressModel?>

// Selected address (for checkout)
final selectedAddressProvider = StateProvider<AddressModel?>
```

---

## API Documentation

### Base URL
```
Development: http://localhost:3000/api/v1
Production: https://api.smartfood.app/api/v1
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/send-otp` | Send OTP to phone |
| POST | `/auth/verify-otp` | Verify OTP and login |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout user |

### User Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/user/profile` | Get user profile |
| PUT | `/user/profile` | Update profile |
| PUT | `/user/health-goals` | Update health goals |
| PUT | `/user/dietary-preferences` | Update dietary preferences |
| PUT | `/user/daily-routine` | Update daily routine |
| GET | `/user/addresses` | Get user addresses |
| POST | `/user/addresses` | Add address |
| PUT | `/user/addresses/:id` | Update address |
| DELETE | `/user/addresses/:id` | Delete address |

### Food Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/food/categories` | Get all categories |
| GET | `/food` | Get foods with filters |
| GET | `/food/:id` | Get food details |
| GET | `/food/recommendations/:feeling` | Get recommendations |
| GET | `/food/search/:query` | Search foods |

### Order Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/orders` | Get user orders |
| GET | `/orders/active` | Get active orders |
| GET | `/orders/:id` | Get order details |
| POST | `/orders` | Create order |
| PUT | `/orders/:id/cancel` | Cancel order |
| POST | `/orders/:id/rate` | Rate order |

### Socket.IO Events

**Client → Server**:
- `trackOrder(orderId)` - Subscribe to order updates
- `stopTrackingOrder(orderId)` - Unsubscribe

**Server → Client**:
- `orderUpdate` - Order status/location update
- `newOrder` - New order notification

---

## Backend Setup

### Environment Variables

Create `.env` file in `/backend` directory:

```env
# Server
PORT=3000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/smartfood

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Twilio (for OTP)
TWILIO_ACCOUNT_SID=your-twilio-account-sid
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+1234567890

# Paymob (for payments)
PAYMOB_API_KEY=your-paymob-api-key
PAYMOB_INTEGRATION_ID=your-integration-id

# AWS S3 (for images)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_BUCKET_NAME=smartfood-images
AWS_REGION=eu-central-1
```

### Seeding Database

```bash
cd backend
node src/seeds/seedData.js
```

This creates:
- 8 food categories
- 10 sample food items with full functional scores

---

## Configuration

### App Colors (`app_colors.dart`)

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #8B9E6B | Buttons, active states |
| Primary Light | #A8B88A | Hover states |
| Secondary | #D4A574 | Highlights, accents |
| Background | #FAF8F5 | Page backgrounds |
| Surface | #FFFFFF | Cards, modals |
| Text Primary | #2C2C2C | Main text |
| Text Secondary | #6B6B6B | Secondary text |
| Success | #4CAF50 | Success states |
| Warning | #FF9800 | Warning states |
| Error | #E53935 | Error states |

### App Constants (`app_constants.dart`)

```dart
// Validation
static const List<String> validPhonePrefixes = ['10', '11', '12', '15'];
static const int phoneLength = 10;
static const int otpLength = 6;

// Limits
static const int minOrderAmount = 100;
static const int maxCodAmount = 2000;

// Durations
static const Duration splashDuration = Duration(seconds: 2);
static const Duration otpResendDuration = Duration(seconds: 45);
```

---

## Localization (Arabic + RTL)

The app uses Flutter ARB localization with generated `AppLocalizations`, and supports both English (LTR) and Arabic (RTL).

### Files

- `lib/l10n/app_en.arb` (English strings)
- `lib/l10n/app_ar.arb` (Arabic strings)
- `lib/l10n/app_localizations.dart` (generated by `flutter gen-l10n`)
- `lib/core/localization/l10n_extensions.dart` (context extensions + dynamic translation map)

### Runtime Setup

- `MaterialApp.router` is wired with:
  - `AppLocalizations.delegate`
  - `GlobalMaterialLocalizations.delegate`
  - `GlobalWidgetsLocalizations.delegate`
  - `GlobalCupertinoLocalizations.delegate`
- `supportedLocales: AppLocalizations.supportedLocales`
- Locale is managed by `localeProvider`
- Selected language is persisted via `StorageKeys.appLanguage`

### User Language Switching

- Location in app: **Profile → Settings → Language**
- Supported values:
  - English (`en`)
  - Arabic (`ar`)
- Switching updates app strings and layout direction immediately.

### Dynamic Content Translation

Some text is dynamic (food names, category names, tags, option labels). For these values:

- Use `myString.localize(context)`
- Maintain mappings in `_dynamicArMap` inside `lib/core/localization/l10n_extensions.dart`

### Localized Core Screens/Flows

- Main shell bottom navigation
- Home screen (greetings, quick actions, feeling cards, section titles)
- Categories screen
- Recommendations screen
- Food cards and food detail
- Profile screen and language picker

### Adding New Translations

1. Add key/value in `lib/l10n/app_en.arb`
2. Add corresponding Arabic translation in `lib/l10n/app_ar.arb`
3. Run:

```bash
flutter gen-l10n
```

4. Use in widgets with `context.l10n.<key>`
5. For dynamic/mock text, add mapping in `_dynamicArMap` and call `.localize(context)`

---

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Analyzing Code

```bash
# Check for issues
flutter analyze

# Format code
dart format lib/
```

---

## Troubleshooting

### Common Issues

#### 1. Build Runner Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. iOS Build Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run -d ios
```

#### 3. Android Build Issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run -d android
```

#### 4. MongoDB Connection Failed
- Check `MONGODB_URI` in `.env`
- Ensure IP is whitelisted in MongoDB Atlas
- Verify network connectivity

#### 5. OTP Not Receiving
- Check Twilio credentials in `.env`
- Verify phone number format (+20XXXXXXXXXX)
- Check Twilio dashboard for errors

---

## Version Support Matrix

| Flutter Version | Dart Version | Status |
|-----------------|--------------|--------|
| 3.32.x | 3.8.x | ✅ Supported |
| 3.24.x | 3.5.x | ✅ Supported |
| 3.19.x | 3.3.x | ⚠️ May work |
| < 3.19 | < 3.3 | ❌ Not supported |

---

## License

Proprietary - All rights reserved

---

## Support

For questions or issues:
- Email: support@smartfood.app
- Documentation: https://docs.smartfood.app
