<div align="center">

# 🚀 ORBIT AI
### The Next-Generation Intelligent Educational Platform

<p>
  <img src="https://img.shields.io/badge/Angular-18.x-DD0031?style=for-the-badge&logo=angular&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3.10-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/WebRTC-PeerJS-333333?style=for-the-badge&logo=webrtc&logoColor=white" />
  <img src="https://img.shields.io/badge/InsightFace-AI-FF6F00?style=for-the-badge&logo=openai&logoColor=white" />
  <img src="https://img.shields.io/badge/Whisper-AI-000000?style=for-the-badge&logo=openai&logoColor=white" />
</p>

<p>
  <strong>A microservices-driven education portal blending live synchronous teaching with asynchronous AI-powered tools.</strong>
</p>

</div>

---

## 🔗 Project Repositories

ORBIT is built using a microservices architecture. The codebase is split across several specific Git repositories for modularity and scaling:

| Module | Repository Link | Stack | Description |
|--------|----------------|-------|-------------|
| **[FRONTEND] App** | [Srikarsanka/orbit](https://github.com/Srikarsanka/orbit) | Angular, Tailwind | The client-facing Web UI for students and faculty |
| **[BACKEND] Core** | [Srikarsanka/orbitbackend](https://github.com/Srikarsanka/orbitbackend) | Node.js, Express, Mongo | Core API, Video Call Signaling, WebRTC endpoints |
| **[AI] Face & Exec** | [Srikarsanka/pythonfacerecognizationorbit](https://github.com/Srikarsanka/pythonfacerecognizationorbit) | Python, FastAPI | Face Recognition biometric logins & Code Compilation |
| **[AI] Translator** | [Srikarsanka/orbittranslate](https://github.com/Srikarsanka/orbittranslate) | Python, Whisper, FFmpeg | AI Audio extraction and Multi-language Translation |
| **[ROOT] System** | [Srikarsanka/orbitai](https://github.com/Srikarsanka/orbitai) | Markdown, Configs | Master repository connecting global architecture docs |

---

## 🏗️ Architecture: Simple Overview

At a high level, ORBIT connects users to a central Node.js gateway that handles database reading, live class connections, and routing to specialized AI Python engines.

```mermaid
graph LR
    User[User Browser] <-->|Traffic| Gateway[Node.js Backend Gateway]
    
    Gateway -->|Database| DB[(MongoDB)]
    Gateway -->|Biometrics / Code| AI1[Python AI Service]
    Gateway -->|Video Translation| AI2[Whisper Translator Service]
    
    style Gateway fill:#339933,color:#fff,stroke:#166534
    style AI1 fill:#3776ab,color:#fff,stroke:#1f4c7a
    style AI2 fill:#6366f1,color:#fff,stroke:#4f46e5
```

---

## 🏗️ Architecture: In-Depth Technical Flow

```mermaid
graph TD
    subgraph Frontend Application
        UI[Angular 18 Single Page App]
        VPlayer[Static Video & Transcript Player]
    end

    subgraph Node.js Core Backend
        API[Express REST API]
        Socket[Socket.io Signaling Server]
        Auth[JWT Authentication]
        WBO[Whiteboard Integration]
    end
    
    subgraph Real-Time Communication
        PeerJS[PeerJS WebRTC Server]
        Media[(Browser Media Streams)]
    end

    subgraph AI Microservice 1: Face & Code
        FastAPI_1[FastAPI Engine]
        InsightFace[InsightFace buffalo_l]
        Exec[Multi-lang Code Compiler]
    end

    subgraph AI Microservice 2: Voice Translation
        FastAPI_2[FastAPI Engine]
        FFmpeg[Video/Audio Extractor]
        Whisper[OpenAI Whisper Base]
        GTTS[Google Text-to-Speech]
    end

    %% Connections
    UI -->|HTTP Requests| API
    UI -->|WebSocket| Socket
    Socket <-->|Signaling Offers/Answers| PeerJS
    PeerJS <--> Media
    
    API -->|Validation & Encodes| FastAPI_1
    FastAPI_1 --> InsightFace
    FastAPI_1 --> Exec
    
    VPlayer -->|Transcription Video URL Proxy| API
    API -->|Translate Job| FastAPI_2
    FastAPI_2 --> FFmpeg
    FFmpeg --> Whisper --> GTTS
    
    %% Styling
    style UI fill:#dd0031,color:#fff,stroke:#990022
    style API fill:#339933,color:#fff,stroke:#166534
    style Socket fill:#010101,color:#fff,stroke:#000
    style FastAPI_1 fill:#009688,color:#fff,stroke:#00796b
    style FastAPI_2 fill:#4f46e5,color:#fff,stroke:#3730a3
    style Whisper fill:#f59e0b,color:#fff,stroke:#d97706
```

---

## 🛠️ Global Commands & Setup

Because ORBIT uses multiple repositories and microservices, starting the entire environment locally requires running the specific services.

### 1️⃣ Clone All Repositories
Since the system is decoupled, clone them into a central `ORBIT` folder:

```bash
mkdir ORBIT && cd ORBIT
git clone https://github.com/Srikarsanka/orbit.git frontend
git clone https://github.com/Srikarsanka/orbitbackend.git backend
git clone https://github.com/Srikarsanka/pythonfacerecognizationorbit.git backend/python
git clone https://github.com/Srikarsanka/orbittranslate.git backend/voice_translation
```

### 2️⃣ Start The Core Backend (Gateway)
```bash
cd backend
npm install
npm run dev
# Starts on http://localhost:5000
```

### 3️⃣ Start the Frontend Web App
```bash
cd frontend
npm install
ng serve
# Starts on http://localhost:4200
```

### 4️⃣ Start Python AI & Code Execution Service
```bash
cd backend/python
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
# Starts on http://localhost:8000
```

### 5️⃣ Start Voice Translation Docker Service
```bash
cd backend/voice_translation
docker build -t orbit-voice-translation .
docker run -d --name orbit-vt -p 8001:8001 orbit-voice-translation
# Starts on http://localhost:8001
```

---

<div align="center">

### Built strategically to scale from classrooms to global learning.

</div>
