# Faculty Dashboard Documentation

## 1. Overview
The Faculty Dashboard provides tools to manage classrooms, schedule sessions, and monitor student engagement.

## 2. Key Features
- Create Class: Generate new courses with unique codes.
- Schedule Class: Set recurring or one-time sessions.
- Start Class: Instant button to open the video room.
- Analytics: View attendance reports and engagement metrics.

## 3. Workflow Diagram (Start Class)

```mermaid
sequenceDiagram
    participant Fac as Faculty
    participant UI as Dashboard
    participant API as Backend
    participant DB as Database
    
    Fac->>UI: Click "Start Class"
    UI->>API: POST /api/openclass/start
    API->>DB: Create Active Session
    API-->>UI: Return Room ID
    UI->>Fac: Redirect to Video Room
    
    Note right of Fac: Students can now join
```

## 4. Component Structure
- `FacultyDashboardComponent`: Main layout.
- `CreateClassComponent`: Form for new classes.
- `SchedulerComponent`: Calendar interface.

## 5. Unique Functionality
- Dynamic Code Generation: Automatically generates a 6-char unique code upon class creation.
- Session Tracking: Automatically logs session start/end times for payroll/attendance.
