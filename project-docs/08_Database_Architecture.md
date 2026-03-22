# Database Architecture

## 1. Overview
The application uses **MongoDB** as its primary data store, managed via the **Mongoose** ODM. It uses a schema-based approach to ensure data consistency.

## 2. Key Models

### 2.1 User (`models/user.js`)
Stores account information for Students and Faculty.
- Role: `student` | `faculty` | `admin`.
- FaceData: Encrypted biometric embedding.
- Profile: Name, Email, Photo URL.

### 2.2 Class (`models/class.js`)
Represents a virtual classroom.
- Code: Unique 6-character alphanumeric code.
- Faculty: Reference to the creator (`User`).
- Students: Array of enrolled student IDs.
- Schedule: Recurring time slots.

### 2.3 Session (`models/sessions.js`)
Tracks active video call sessions and attendance.
- Room: Link to Class.
- Attendees: List of users present.
- Duration: Start/End timestamps.

### 2.4 OTP (`models/otp.js`)
Temporary storage for password reset codes.
- TTL: Automatically deleted after 5 minutes.

## 3. Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ CLASS : "teaches (Faculty)"
    USER ||--o{ CLASS : "enrolls (Student)"
    USER ||--o{ OTP : "requests"
    
    CLASS ||--o{ SESSION : "hosts"
    CLASS ||--o{ MATERIAL : "contains"
    CLASS ||--o{ ASSIGNMENT : "assigned"
    
    SESSION ||--o{ ATTENDANCE : "tracks"
    
    USER {
        ObjectId _id
        string email
        string password_hash
        string role
        string faceEmbedding_encrypted
    }
    
    CLASS {
        ObjectId _id
        string name
        string subjectCode
        ObjectId facultyId
    }
    
    OTP {
        string email
        string otp_hash
        Date expiresAt
    }
```

## 4. Scaling Strategy
- Indexing: Fields like `email`, `classCode` are indexed for O(1) lookups.
- Sharding: Ready for horizontal scaling if user base grows (Active configurations pending).
