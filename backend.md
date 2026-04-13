# Mnyama collect - Animal Disease AI Backend Documentation

## 📋 Project Overview

**Mnyama collect** is a production-ready Node.js backend API designed for **AI-powered animal disease training data collection and management**. It provides a robust system for collecting, storing, and managing veterinary disease cases with image uploads, user authentication, and role-based access control.

**Current Status**: Core features implemented | Firebase integration pending

---

## 🎯 Project Purpose

The system enables:
- Trainers and researchers to submit animal disease cases with clinical data
- Collection of labeled training data for AI/ML disease detection models
- Secure image storage for disease case documentation
- Administrative review and approval workflow for case quality control

---

## 🛠 Technology Stack

### Backend Framework
- **Runtime**: Node.js + TypeScript
- **Framework**: Express.js (lightweight REST API)
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT (JSON Web Tokens) + bcrypt

### Storage & External Services
- **Primary Storage**: Supabase Storage (currently used for case images)
- **File Uploads**: Multer (memory storage → cloud upload)
- **Containerization**: Docker + Docker Compose

### Development Tools
- **Build**: TypeScript Compiler (tsc)
- **Package Manager**: npm
- **Development Server**: tsx (TypeScript execution)
- **API Documentation**: Zod (schema validation)

### Security & Utilities
- **Security Headers**: Helmet
- **Cross-Origin Requests**: CORS
- **Logging**: Morgan HTTP request logger
- **Password Hashing**: bcryptjs
- **Validation**: Zod schemas
- **Environment Management**: dotenv

---

## 📁 Project Structure

```
Mnyama-collect/
├── src/                        # Source code
│   ├── app.ts                 # Express app configuration
│   ├── server.ts              # Server entry point
│   ├── config/                # Configuration files
│   │   ├── env.ts             # Environment variables
│   │   ├── prisma.ts          # Prisma client
│   │   └── supabase.ts        # Supabase client
│   ├── middleware/            # Express middleware
│   │   ├── auth.middleware.ts # JWT verification
│   │   ├── error.middleware.ts# Error handling
│   │   └── validate.middleware.ts # Schema validation
│   ├── modules/               # Feature modules (organized by domain)
│   │   ├── auth/              # User authentication
│   │   ├── users/             # User management
│   │   ├── cases/             # Case management (core feature)
│   │   ├── disease-labels/    # Disease taxonomy
│   │   └── uploads/           # File upload utilities
│   ├── routes/                # API route definitions
│   ├── supabase/              # Storage RLS policies
│   ├── prisma/                # Prisma client & types
│   ├── types/                 # TypeScript definitions
│   └── utils/                 # Shared utilities
├── prisma/                    # Database schema & migrations
│   ├── schema.prisma          # Data model definitions
│   ├── seed.ts                # Database seeding script
│   └── migrations/            # Auto-generated migrations
├── docker-compose.yml         # Container orchestration
├── Dockerfile                 # Docker image definition
├── tsconfig.json              # TypeScript configuration
├── package.json               # Project dependencies
└── .env                       # Environment variables (git-ignored)
```

---

## 💾 Data Models

### Core Entities

#### **User**
Represents system users with role-based access control:
```typescript
- id: UUID
- fullName: String
- email: String (unique)
- passwordHash: String (bcrypted)
- role: ADMIN | TRAINER | RESEARCHER
- createdAt: DateTime
- updatedAt: DateTime
```

#### **DiseaseLabel**
Disease taxonomy/classification system:
```typescript
- id: UUID
- code: String (unique) - e.g., "FMD001"
- name: String - Disease name
- animalType: String - Target animal species
- createdAt: DateTime
- updatedAt: DateTime
```

#### **Case**
Animal disease case submission (core feature):
```typescript
- id: UUID
- userId: Foreign Key (User)
- diseaseLabelId: Foreign Key (DiseaseLabel)
- animalType: String - Species (e.g., cow, sheep)
- breed: String (optional)
- ageMonths: Int (optional)
- gender: MALE | FEMALE | UNKNOWN
- symptoms: String - Clinical presentation
- diagnosis: String (optional) - Final diagnosis
- notes: String (optional) - Additional context
- farmLocation: String (optional)
- severity: MILD | MODERATE | SEVERE | CRITICAL
- status: SUBMITTED | UNDER_REVIEW | APPROVED | REJECTED
- createdAt: DateTime
- updatedAt: DateTime
- images: CaseImage[] - Related images
```

#### **CaseImage**
Stores metadata for case images:
```typescript
- id: UUID
- caseId: Foreign Key (Case)
- imageUrl: String - Public URL (storage reference)
- fileName: String - Stored file name
- mimeType: String - Image MIME type
- fileSize: Int - Bytes
- createdAt: DateTime
```

---

## ✅ What Has Been Implemented

### 1. **User Authentication & Authorization**
- ✅ User registration with email + password
- ✅ Login with JWT token generation
- ✅ Password hashing with bcryptjs
- ✅ JWT middleware for protected routes
- ✅ Role-based access control (ADMIN, TRAINER, RESEARCHER)
- **Files**: `src/modules/auth/`, `src/middleware/auth.middleware.ts`

### 2. **User Management**
- ✅ User creation and retrieval
- ✅ Email-based user lookup
- ✅ User profile with role assignment
- **Files**: `src/modules/users/`

### 3. **Disease Label Management**
- ✅ Create disease classifications
- ✅ List all disease labels with pagination
- ✅ Retrieve disease details by ID
- ✅ Unique disease codes for tracking
- **Files**: `src/modules/disease-labels/`

### 4. **Case Management (Core Feature)**
- ✅ Create disease cases with clinical data
- ✅ List cases with filtering (by disease, animal type)
- ✅ Retrieve case details with related data
- ✅ Update case status (workflow: SUBMITTED → UNDER_REVIEW → APPROVED/REJECTED)
- ✅ Pagination support for case listings
- ✅ Automatic user association
- **Files**: `src/modules/cases/cases.service.ts`, `src/modules/cases/cases.routes.ts`

### 5. **Image Upload & Storage**
- ✅ Multer integration for file uploads (memory storage)
- ✅ Image metadata validation (MIME type, file size ≤10MB)
- ✅ Upload files to Supabase Storage
- ✅ Generate public URLs for stored images
- ✅ Delete images from storage
- ✅ Store image metadata in database (CaseImage model)
- **Files**: `src/modules/uploads/supabase.util.ts`

### 6. **API Foundation**
- ✅ Express.js server setup
- ✅ RESTful route structure: `/api/auth`, `/api/users`, `/api/cases`, `/api/disease-labels`
- ✅ Error handling middleware with custom error responses
- ✅ 404 handler for undefined routes
- ✅ CORS configuration for cross-origin requests
- ✅ Security headers with Helmet
- ✅ Request logging with Morgan
- ✅ Health check endpoint: `GET /health`

### 7. **Database & ORM**
- ✅ PostgreSQL database setup
- ✅ Prisma ORM with auto-generated migrations
- ✅ Database seeding script (`prisma/seed.ts`)
- ✅ Relational models with foreign keys
- ✅ Database indexes for query optimization
- ✅ Cascade delete policies

### 8. **Validation & Error Handling**
- ✅ Zod schema validation for request bodies
- ✅ Custom ApiError class for consistent error responses
- ✅ Input sanitization
- ✅ Type-safe request/response handling
- **Files**: `src/utils/ApiError.ts`, `src/modules/*/schemas.ts`

### 9. **Environment Configuration**
- ✅ .env file support with dotenv
- ✅ Configuration for database, JWT, CORS, Supabase
- ✅ Environment-based settings (development/production)

### 10. **Docker Support**
- ✅ Dockerfile for containerization
- ✅ Docker Compose for local development (PostgreSQL + API)
- ✅ Volume management for database persistence

---

## 🔄 API Endpoints (Implemented)

### Authentication
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---|
| POST | `/api/auth/register` | Register new user | ❌ |
| POST | `/api/auth/login` | Login and get JWT token | ❌ |

### Cases (Main Feature)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---|
| POST | `/api/cases` | Create new disease case | ✅ |
| GET | `/api/cases` | List all cases (with pagination) | ✅ |
| GET | `/api/cases/:id` | Get case details | ✅ |
| POST | `/api/cases/:id/images` | Upload images to case | ✅ |
| DELETE | `/api/cases/:id/images/:imageId` | Delete image from case | ✅ |

### Disease Labels
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---|
| POST | `/api/disease-labels` | Create disease label | ✅ (ADMIN) |
| GET | `/api/disease-labels` | List all disease labels | ✅ |
| GET | `/api/disease-labels/:id` | Get disease label details | ✅ |

---

## 🚀 How to Run the Project

### Prerequisites
- Node.js v18+
- Docker & Docker Compose
- PostgreSQL (or use Docker Compose version)

### Local Development

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Setup environment variables**
   ```bash
   # Copy .env.example to .env and fill in values
   cp .env.example .env
   ```

3. **Start database with Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**
   ```bash
   npm run prisma:migrate
   ```

5. **Seed sample data** (optional)
   ```bash
   npx prisma db seed
   ```

6. **Start development server**
   ```bash
   npm run dev
   ```
   Server runs on `http://localhost:4000`

### Production Build
```bash
npm run build
npm start
```

---

## 🔐 Security Features Implemented

| Feature | Status | Details |
|---------|--------|---------|
| Password Hashing | ✅ | bcryptjs with salt rounds: 12 |
| JWT Authentication | ✅ | Signed tokens with expiration (default: 7 days) |
| CORS Protection | ✅ | Configurable origins for cross-origin requests |
| Security Headers | ✅ | Helmet.js for HTTP security headers |
| Input Validation | ✅ | Zod schemas for request validation |
| SQL Injection Prevention | ✅ | Prisma ORM parameterized queries |
| File Upload Validation | ✅ | MIME type & size limits (10MB max) |
| Role-Based Access Control | ✅ | ADMIN, TRAINER, RESEARCHER roles |

---

## ❌ What Still Needs to Be Integrated

### 🔥 Firebase Integration (TODO)

Firebase needs to be integrated for:

#### 1. **Firebase Storage for Image Backup**
   - **Purpose**: Secondary backup storage for all case images
   - **Why**: Redundancy, disaster recovery, multi-cloud strategy
   - **Current State**: Only Supabase is used
   - **Work Required**:
     - Install `firebase-admin` SDK (already in `package.json` v13.8.0 ✅)
     - Create Firebase service account credentials (JSON file)
     - Initialize Firebase Admin SDK
     - Implement dual-upload: upload to both Supabase AND Firebase Storage
     - Store Firebase URL alongside Supabase URL in `CaseImage` model
     - Add retry logic if one cloud fails

   **Implementation Location**: `src/modules/uploads/firebase.util.ts` (NEW)

#### 2. **Firebase Firestore for Case Data Backup**
   - **Purpose**: Real-time backup database for case records and metadata
   - **Why**: Data redundancy, real-time sync for mobile/web apps, document querying
   - **Current State**: Only PostgreSQL is used
   - **Work Required**:
     - Create Firestore collection structure:
       ```
       /cases/{caseId}
         ├── patientInfo
         ├── diseaseData
         ├── images[] (array of URLs)
         └── metadata
       
       /users/{userId}
         ├── profile
         └── submittedCases[]
       ```
     - After each case creation in PostgreSQL, mirror to Firestore
     - Setup real-time listeners for data sync
     - Implement conflict resolution policy
     - Add data migration script (PostgreSQL → Firestore)

   **Implementation Location**: `src/modules/cases/firebase-sync.service.ts` (NEW)

#### 3. **Firebase Cloud Storage File Size Optimization**
   - **Purpose**: Automatic image compression and format optimization
   - **Current State**: Full-size images uploaded as-is (10MB limit)
   - **Work Required**:
     - Create multiple image versions:
       - Original (full resolution)
       - Thumbnail (200x200px for UI)
       - Compressed (1920x1080px for web)
     - Use Firebase Cloud Functions or imgix API
     - Store all versions and track in database

   **Implementation Location**: `src/modules/uploads/image-optimization.service.ts` (NEW)

---

## 📋 Firebase Integration Checklist

- [ ] Create Firebase project at console.firebase.google.com
- [ ] Download service account JSON and add to `src/assets/`
- [ ] Add Firebase configuration to `.env`:
  ```env
  FIREBASE_PROJECT_ID=your-project-id
  FIREBASE_PRIVATE_KEY=your-private-key
  FIREBASE_CLIENT_EMAIL=your-client-email
  ```
- [ ] Create `src/config/firebase.ts` - Firebase Admin SDK initialization
- [ ] Create `src/modules/uploads/firebase.util.ts` - Storage upload/download functions
- [ ] Create `src/modules/cases/firebase-sync.service.ts` - Firestore sync logic
- [ ] Update `CaseImage` model with `firebaseUrl` field
- [ ] Create migration: `prisma migrate dev --name add_firebase_storage_fields`
- [ ] Update case creation to upload to both Supabase and Firebase
- [ ] Update case deletion to remove from both storages
- [ ] Add rollback mechanism if Firebase upload fails
- [ ] Create backup sync endpoint: `GET /api/admin/sync-to-firebase`
- [ ] Add error monitoring/alerting for failed syncs

---

## 📊 Development Workflow for Junior Developers

### 1. **Understanding the Code Structure**
   - Each feature is in `src/modules/{feature}/`
   - Each module contains:
     - `.service.ts` - Business logic (database operations)
     - `.controller.ts` - Request/response handling
     - `.routes.ts` - API endpoint definitions
     - `.schemas.ts` - Input validation schemas

### 2. **Making a Simple Change**
   Example: Add a new field to case (e.g., treatment type)

   **Step 1**: Update database schema
   ```typescript
   // prisma/schema.prisma
   model Case {
     // ... existing fields
     treatmentType: String?  // New field
   }
   ```

   **Step 2**: Create migration
   ```bash
   npm run prisma:migrate -- --name add_treatment_type
   ```

   **Step 3**: Update API schema validation
   ```typescript
   // src/modules/cases/cases.schemas.ts
   export const CreateCaseInput = z.object({
     // ... existing fields
     treatmentType: z.string().optional()
   });
   ```

   **Step 4**: Update service/controller
   ```typescript
   // src/modules/cases/cases.service.ts
   return prisma.case.create({
     data: {
       // ...
       treatmentType: input.treatmentType
     }
   });
   ```

### 3. **Testing an Endpoint**
   Use the provided examples with curl or Postman:
   ```bash
   # Create a case
   curl -X POST http://localhost:4000/api/cases \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"diseaseLabelId":"...", "animalType":"cow", ...}'
   ```

### 4. **Debugging**
   - Check PostgreSQL logs: `docker-compose logs postgres`
   - Check API server logs (in terminal output)
   - Add console.log() for debugging (will appear in terminal)
   - Check database state with: `npx prisma studio`

---

## 🔧 Common Tasks

### Run Database Migrations
```bash
npm run prisma:migrate
```

### View Database in UI
```bash
npx prisma studio
```

### Seed Initial Data
```bash
npx prisma db seed
```

### TypeScript Compilation
```bash
npm run build
```

### Development Server
```bash
npm run dev
```

### Production Start
```bash
npm start
```

---

## 📝 Environment Variables Required

```env
# Server
NODE_ENV=development
PORT=4000

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# JWT
JWT_SECRET=your-secret-key-min-32-chars
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=*

# Supabase (Currently Active)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_BUCKET=image

# Firebase (TO BE ADDED)
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=
```

---

## 📈 Next Steps for Development

### Immediate (Priority 1)
1. Complete Firebase integration (see checklist above)
2. Add image compression/optimization
3. Implement backup sync verification

### Short Term (Priority 2)
1. Add user profile management endpoints
2. Implement case status update workflow
3. Add filtering by date range
4. Create admin dashboard endpoints

### Long Term (Priority 3)
1. AI model integration for auto-diagnosis
2. Real-time WebSocket support for live updates
3. Advanced analytics and reporting
4. Mobile app API support

---

## 🤝 Contributing Guidelines

1. **Create new features in modules** - Always follow the modular structure
2. **Add validation schemas** - Use Zod for all inputs
3. **Write error handling** - Use custom ApiError class
4. **Update types** - TypeScript should have zero errors
5. **Test endpoints** - Use Postman or curl before pushing
6. **Document changes** - Update this README if structure changes

---

## 📞 Support & Documentation

- **Prisma Docs**: https://www.prisma.io/docs/
- **Express Guides**: https://expressjs.com/
- **Supabase Storage**: https://supabase.com/docs/guides/storage
- **Firebase Docs**: https://firebase.google.com/docs/
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/

---

**Last Updated**: April 2026  
**Version**: 1.0.0 (Core features complete, Firebase pending)
