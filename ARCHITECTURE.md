# Flutter Authentication System Architecture

## 🏗️ System Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      Flutter App (UI Layer)                    │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  Login Screen    │  │ Register Screen  │  │ Home Screen  │ │
│  │  (login_screen)  │  │(register_screen) │  │(home_screen) │ │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘ │
│           │                     │                   │          │
│           └─────────────────────┼───────────────────┘          │
│                                 ▼                               │
│                    ┌────────────────────────┐                  │
│                    │   Auth Wrapper         │                  │
│                    │  (auth_wrapper.dart)   │                  │
│                    │  - Route Management    │                  │
│                    └────────────┬───────────┘                  │
│                                 │                               │
└─────────────────────────────────┼───────────────────────────────┘
                                  │
┌─────────────────────────────────┼───────────────────────────────┐
│                   State Management Layer (Provider)             │
├─────────────────────────────────┼───────────────────────────────┤
│                                 │                               │
│                    ┌────────────▼──────────┐                   │
│                    │  AuthProvider         │                   │
│                    │ (auth_provider.dart)  │                   │
│                    │ - User State          │                   │
│                    │ - Token Mgmt          │                   │
│                    │ - Login/Register      │                   │
│                    │ - Logout              │                   │
│                    │ - Validation          │                   │
│                    └──────────┬─────────┬──┘                   │
│                               │         │                       │
└───────────────────────────────┼─────────┼───────────────────────┘
                                │         │
┌───────────────────────────────┼─────────┼───────────────────────┐
│                    Service Layer (Business Logic)              │
├───────────────────────────────┼─────────┼───────────────────────┤
│                               │         │                       │
│         ┌─────────────────────▼─┐   ┌──▼──────────────────┐   │
│         │   Auth Service        │   │  Token Service      │   │
│         │ (auth_service.dart)   │   │(token_service.dart) │   │
│         │ - Register API Call   │   │ - Save Token        │   │
│         │ - Login API Call      │   │ - Get Token         │   │
│         │ - Parse Response      │   │ - Validate Token    │   │
│         │ - Error Handling      │   │ - Clear Token       │   │
│         └──────────┬────────────┘   └────────────────────┘   │
│                    │                                           │
└────────────────────┼───────────────────────────────────────────┘
                     │
┌────────────────────┼───────────────────────────────────────────┐
│                 HTTP Layer & Storage                           │
├────────────────────┼───────────────────────────────────────────┤
│                    │                                           │
│  ┌─────────────────▼──────┐        ┌──────────────────────┐  │
│  │  HTTP Client            │        │ SharedPreferences    │  │
│  │  (http package)         │        │ (Local Storage)      │  │
│  │ - POST /auth/register   │        │ - JWT Token          │  │
│  │ - POST /auth/login      │        │ - User ID            │  │
│  └──────────┬──────────────┘        └──────────────────────┘  │
│             │                                                   │
└─────────────┼───────────────────────────────────────────────────┘
              │
              │ HTTPS/HTTP
              │
┌─────────────▼───────────────────────────────────────────────────┐
│               Backend API (Node.js/Express)                     │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  POST /api/auth/register   ──→  Create User + JWT Token         │
│  POST /api/auth/login      ──→  Verify + JWT Token              │
│                                                                   │
│  Response: { token, user: { id, fullName, email, role } }       │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
             ▲                                  ▼
             │                        PostgreSQL Database
             │                        (User, Auth Data)
             └────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

### Registration Flow
```
User Input Form
      │
      ▼
AuthProvider.register()
      │
      ├→ Validation
      │  ├─ Check empty fields
      │  ├─ Validate email format
      │  ├─ Check password length (min 6)
      │  └─ Match passwords
      │
      ├→ (If valid)
      │  └─ AuthService.register()
      │     │
      │     ├→ HTTP POST /api/auth/register
      │     │
      │     ├→ Backend processes (bcrypt, save to DB)
      │     │
      │     └─ Response: { token, user }
      │
      ├→ TokenService.saveToken()
      │  └─ Save JWT to SharedPreferences
      │
      ├→ Update State
      │  ├─ user = response.user
      │  ├─ token = response.token
      │  └─ isAuthenticated = true
      │
      └→ AuthWrapper navigates to HomeScreen
```

### Login Flow
```
User Enters Email & Password
      │
      ▼
AuthProvider.login()
      │
      ├→ Validation
      │  ├─ Check empty fields
      │  └─ Validate email format
      │
      ├→ (If valid)
      │  └─ AuthService.login()
      │     │
      │     ├→ HTTP POST /api/auth/login
      │     │
      │     ├→ Backend verifies credentials
      │     │
      │     └─ Response: { token, user }
      │
      ├→ TokenService.saveToken()
      │  └─ JWT saved to SharedPreferences
      │
      ├→ Update State
      │  ├─ user = response.user
      │  ├─ token = response.token
      │  └─ isAuthenticated = true
      │
      └→ AuthWrapper navigates to HomeScreen
```

### App Startup Flow
```
App Starts
      │
      ▼
MyApp initializes MultiProvider
      │
      ├→ AuthProvider created
      │  │
      │  └─ _checkAuthStatus()
      │     │
      │     ├→ TokenService.getToken()
      │     │  └─ Check SharedPreferences
      │     │
      │     ├→ TokenService.isTokenValid()
      │     │  └─ Check JWT expiration
      │     │
      │     ├→ If valid → isAuthenticated = true
      │     │
      │     └─ If invalid → isAuthenticated = false
      │
      ▼
AuthWrapper checks isAuthenticated
      │
      ├→ true  → Navigate to HomeScreen
      └→ false → Navigate to LoginScreen
```

---

## 🔐 Security Architecture

```
┌──────────────────────────────────────────────────────┐
│              Security Layers                         │
├──────────────────────────────────────────────────────┤
│                                                       │
│ Layer 1: Frontend Validation                         │
│  ├─ Email format validation                          │
│  ├─ Password length requirements (min 6 chars)       │
│  └─ Required field checks                            │
│                                                       │
│ Layer 2: Secure Storage                              │
│  ├─ JWT stored in SharedPreferences                  │
│  ├─ Token expiration validation                      │
│  └─ Secure logout (token cleared)                    │
│                                                       │
│ Layer 3: API Communication                           │
│  ├─ Authorization header with Bearer token           │
│  ├─ HTTPS/HTTP communication                         │
│  └─ Error handling (no sensitive info leaked)        │
│                                                       │
│ Layer 4: Backend Security (in backend.md)            │
│  ├─ Bcryptjs password hashing (12 salt rounds)       │
│  ├─ JWT signed tokens with expiration                │
│  ├─ Parameterized queries (Prisma ORM)               │
│  ├─ CORS protection                                  │
│  ├─ Input validation                                 │
│  └─ Role-based access control                        │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## 📱 State Management Structure

```
AuthProvider (ChangeNotifier)
│
├─ Private Variables:
│  ├─ _user: User?              (Current user object)
│  ├─ _token: String?           (JWT token)
│  ├─ _isLoading: bool          (Loading indicator)
│  ├─ _error: String?           (Error message)
│  └─ _isAuthenticated: bool    (Auth status)
│
├─ Public Getters:
│  ├─ user: User?
│  ├─ token: String?
│  ├─ isLoading: bool
│  ├─ error: String?
│  └─ isAuthenticated: bool
│
├─ Main Methods:
│  ├─ register()         → Returns bool
│  ├─ login()           → Returns bool
│  ├─ logout()          → Returns Future<void>
│  └─ clearError()      → Clears error message
│
└─ Private Methods:
   └─ _checkAuthStatus()  → Restore session on startup
```

---

## 🔄 Component Interaction

```
┌─────────────────────────────────────────────────────┐
│ UI Components                                       │
│ ├─ LoginScreen                                      │
│ ├─ RegisterScreen                                   │
│ ├─ HomeScreen                                       │
│ └─ AuthWrapper                                      │
└────────────────┬────────────────────────────────────┘
                 │ (Read/Write State)
                 ▼
┌─────────────────────────────────────────────────────┐
│ AuthProvider (State Management)                     │
│ ├─ Manages auth state                               │
│ ├─ Calls services                                   │
│ ├─ Validates input                                  │
│ └─ Notifies listeners on state change               │
└────────────────┬────────────────────────────────────┘
                 │ (Uses Services)
                 ├─────────────┬──────────────┐
                 │             │              │
                 ▼             ▼              ▼
         ┌──────────────┐ ┌────────────┐ ┌──────────────┐
         │ AuthService  │ │TokenService│ │ AppConfig    │
         ├──────────────┤ ├────────────┤ ├──────────────┤
         │- HTTP calls  │ │- JWT mgmt  │ │- Constants   │
         │- Parse JSON  │ │- Storage   │ │- URLs        │
         │- Error hdlg  │ │- Validation│ │- Settings    │
         └──────────────┘ └────────────┘ └──────────────┘
                 │             │
                 │             └──────────┐
                 │                        │
                 ▼                        ▼
            Backend API            SharedPreferences
         (Node.js/Express)         (Device Storage)
```

---

## 📋 Model Relationships

```
User
├─ id: String (UUID)
├─ fullName: String
├─ email: String
├─ role: enum(ADMIN, TRAINER, RESEARCHER)
├─ createdAt: DateTime
└─ updatedAt: DateTime
     ▲
     │ (Returned in)
     │
RegisterRequest → AuthResponse
    ↓              ├─ token: String (JWT)
├─ fullName       └─ user: User
├─ email
└─ password (hashed on backend)
     
LoginRequest
├─ email
└─ password
     │
     └─ → AuthResponse
```

---

## 🚀 Deployment Architecture

```
Development Environment
┌─────────────────────────────────────┐
│  Flutter Dev App (localhost)         │
│  - Hot reload enabled                │
│  └─→ Backend http://10.0.2.2:4000    │
└─────────────────────────────────────┘

Staging Environment
┌──────────────────────────────────────┐
│  Flutter Test App (📱)               │
│  - Points to staging server          │
│  └─→ Backend http://staging.api.com  │
└──────────────────────────────────────┘

Production Environment
┌──────────────────────────────────────┐
│  Flutter Release App (📦)            │
│  - Release build                     │
│  - Network security strict           │
│  └─→ Backend https://api.mnyama.com  │
└──────────────────────────────────────┘
```

---

## 📈 Feature Expansion Points

```
Current Authentication
        │
        ├─→ Add User Roles Check
        │   └─ Role-based UI/Features
        │
        ├─→ Add Case Management
        │   ├─ Create case service
        │   ├─ List cases
        │   └─ Update case status
        │
        ├─→ Add Image Upload
        │   ├─ Image picker
        │   ├─ Upload to Supabase
        │   └─ Store metadata
        │
        ├─→ Add Profile Management
        │   ├─ Edit user info
        │   ├─ Change password
        │   └─ Profile picture
        │
        └─→ Add Advanced Features
            ├─ WebSocket real-time
            ├─ Push notifications
            └─ Offline support
```

