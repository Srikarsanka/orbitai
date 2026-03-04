# Virtual Classroom Architecture and Interview Guide

## Project Overview

The Virtual Classroom is a comprehensive, microservices-driven educational platform designed to replicate and enhance the physical classroom experience in a digital environment. The primary objective of the project is to provide a seamless, interactive, and secure environment for synchronous learning while leveraging artificial intelligence to automate administrative tasks like attendance and lecture transcription. 

From a user perspective, the system provides distinct workflows for students and educators. When a teacher initiates a live session, the system establishes a secure, real-time video broadcasting room. Students authenticate themselves, join the virtual room, and participate via low-latency video and audio streams. Parallel to the video broadcast, a real-time text chat allows for instant communication. The core innovation of the platform lies in its biometric integration: upon entry, the student's camera feed is captured, and an AI model verifies their identity against pre-enrolled data to automatically log attendance, ensuring academic integrity without disrupting the flow of the class. Furthermore, post-lecture recordings are processed by a secondary AI pipeline to generate multi-language transcripts, increasing accessibility for diverse student populations.

## Technology Stack Explanation

The project utilizes a modern, distributed technology stack designed for scalability, real-time performance, and AI integration.

Angular is utilized for the frontend client application because its robust component-based architecture and strict TypeScript typing allow for the development of complex, stateful single-page applications. It handles routing between the dashboard and live video components while maintaining the state of the user's connection.

Node.js with Express serves as the core API gateway and orchestration layer. Node.js was selected due to its asynchronous, event-driven architecture, making it highly efficient at handling numerous concurrent connections required by real-time signaling and chat features.

FastAPI is deployed for the Python-based microservices, specifically handling the AI workloads. FastAPI was chosen for its high performance, native support for asynchronous Python, and automatic API documentation. It efficiently runs heavy computational tasks like image encoding and audio processing without blocking the main web server.

MongoDB is implemented as the primary database. As a NoSQL database, its flexible schema design is ideal for storing varied user data, complex class schedules, and unstructured chat logs.

WebRTC and PeerJS handle the real-time audio and video transmission. WebRTC is the industry standard for browser-based, peer-to-peer communication, offering sub-second latency. PeerJS was selected to abstract the complex STUN/TURN server configurations and signaling logic required to establish WebRTC connections.

Socket.io is utilized as the WebSocket abstraction layer. It provides dual-channel, event-based communication between the server and clients, ensuring that chat messages and system events (like a user joining or leaving) are propagated to all connected clients instantly, with built-in fallback mechanisms for restrictive networks.

InsightFace is the underlying AI model for facial recognition. It provides highly accurate facial feature extraction and embedding, optimized for varying lighting conditions typically found in webcam feeds.

OpenAI Whisper is integrated for post-recording transcription. It is a state-of-the-art automatic speech recognition system robust to various accents and background noise, making it highly suitable for academic lectures.

Docker is utilized for containerizing the application environments, particularly the Python microservices. It ensures that the specific dependencies required by the AI models and ffmpeg binaries remain consistent from local development to production deployment.

Azure Cloud provides the hosting infrastructure. Azure was selected to host the Dockerized microservices via Azure Container Instances, ensuring high availability and providing the compute power necessary to run machine learning models in a production environment.

## System Architecture

The architecture of the Virtual Classroom relies on a microservices design pattern to decouple real-time communication from heavy AI computations. 

The system is divided into three primary layers: the Frontend Client, the Core Node.js Gateway, and the Python AI Microservices layer. When a client performs an operation, the request first hits the Node.js Gateway via a REST API. The Gateway acts as the central router and orchestrator. It directly interacts with the MongoDB database to read or write standard operational data.

When a client requires real-time data exchange, such as sending a chat message, the connection is upgraded from HTTP to WebSockets via Socket.io. The Node.js server maintains these continuous connections in memory, allowing it to broadcast events to specific "rooms" representing active classes.

For live video streaming, the architecture shifts to a peer-to-peer model. The Node.js Gateway acts solely as a signaling server. When a new student joins, the gateway passes connection credentials (SDP offers and answers) between the new student and the existing peers. Once the signaling is complete, the video and audio data flow directly between the clients' browsers via WebRTC, entirely bypassing the Node.js server to conserve bandwidth and reduce latency.

When the Node.js Gateway encounters a task requiring heavy computation, such as biometric verification or audio translation, it acts as a proxy HTTP client. It securely packages the required payload (such as a base64 encoded image or a video URL) and forwards it to the respective Python FastAPI microservice. The Python service performs the computation independently and returns the result to the Gateway, which then responds to the original client request.

## Authentication and Login System

The authentication mechanism is designed around JSON Web Tokens (JWT) to provide stateless, secure user sessions. 

When a user attempts to log in, the frontend sends their credentials (email and password) over HTTPS to the Node.js authentication route. The server validates the credentials and, upon success, generates a cryptographically signed JWT containing the user's unique identifier and role (e.g., student or faculty). This token is returned to the client and stored. Subsequent requests from the client include this token in the Authorization header. Express middleware intercepts these requests, verifies the JWT signature against a secret key, and grants access to protected routes only if the token is valid and unexpired.

During the student login process, a secondary biometric verification step is triggered. The frontend accesses the user's webcam, captures a live snapshot, and transmits it as a base64 encoded string alongside the login request. The Node.js server routes this image to the FastAPI face recognition service. The Python service extracts the facial embeddings from the live snapshot and uses cosine similarity to compare them against the pre-enrolled embeddings stored in the MongoDB user profile. If the similarity score exceeds a predefined threshold, the system confirms the student's physical presence and grants system access.

## Face Based Attendance System

The automated attendance mechanism operates within the live classroom environment to log participation without instructor intervention.

The pipeline begins at the client browser. When a student enters the virtual classroom route, the application accesses the `navigator.mediaDevices.getUserMedia` API to request camera permissions. Once the video stream begins, the Angular component periodically captures a single frame from the video element and draws it onto a hidden HTML5 Canvas element. This canvas converts the frame into a base64 encoded JPEG string.

The frontend transmits this encoded frame via an asynchronous HTTP POST request to the Node.js Gateway, identifying the specific class session and the user's ID. The Node.js server immediately forwards this payload to the Python face recognition microservice to prevent blocking the main event loop.

Inside the Python environment, the base64 string is decoded back into an image matrix (numpy array). The InsightFace model, specifically utilizing the buffalo_l architecture, scans the matrix to detect the presence of a human face using bounding box coordinates. Once a face is detected, the model computes a 512-dimensional vector embedding that numerically represents the unique geometry of the user's face.

This newly generated live embedding is then compared against the registered embedding associated with the student's database profile. The system calculates the Euclidean distance or cosine similarity between the two vectors. If the vectors match closely enough to indicate the same individual, the Python service returns a positive boolean result to the Node.js Gateway.

Finally, the Node.js server updates the attendance array within the corresponding ScheduledClass document in MongoDB, appending a timestamp to indicate when the student's presence was biologically verified.

## Real Time Communication

Real-time communication forms the backbone of the virtual classroom experience, utilizing two distinct protocols: WebRTC and WebSockets.

WebRTC (Web Real-Time Communication) is an open-source project that provides web browsers with real-time audio and video capabilities via simple JavaScript APIs. In this architecture, it establishes peer-to-peer (P2P) connections. A P2P topology means that the actual heavy media streams (video and voice) travel directly from one student's computer to the teacher's computer, reducing server costs and minimizing latency since the data takes the shortest path across the internet. 

Establishing a WebRTC connection requires signaling. Browsers must exchange metadata, such as public IP addresses (ICE candidates) and media format capabilities (SDP offers/answers), before they can connect directly. To manage this complex signaling process, the project utilizes the PeerJS library. PeerJS simplifies the raw WebRTC API calls and uses the Node.js server solely to pass the initial connection metadata between peers.

Parallel to the video streams, text-based chat is facilitated by Socket.io, a JavaScript library that wraps the WebSocket protocol. Unlike HTTP requests where the client must actively ask the server for new data, WebSockets maintain a persistent, bidirectional, full-duplex connection. When a student sends a chat message, it is instantly pushed down the open socket to the Node.js server. The server, organizing users into logical "rooms" based on their class ID, immediately broadcasts that message down the sockets of all other clients currently connected to that exact room, resulting in instantaneous chat updates without page reloads.

## Whisper API Integration

The integration of OpenAI's Whisper model provides the platform with automated transcription and translation capabilities for recorded lectures.

The pipeline initiates after a live class concludes and the recorded video file is saved to the cloud storage bucket. When the transcription service is triggered, the Node.js server sends the URL of the saved video file to the Python Voice Translation microservice.

The Python service utilizes the FFmpeg library to probe the video file and systematically extract solely the audio track, converting it into a standardized 16kHz mono WAV format. This preprocessing reduces processing time and optimizes the audio for the AI model.

The processed audio file is then fed into the Whisper base model. Whisper is a sequence-to-sequence transformer model trained on massive amounts of multilingual audio data. It processes the audio in discrete segments, mapping the audio waveforms to text tokens to generate highly accurate transcriptions along with precise timestamps.

Once the English text is generated, the pipeline can optionally pass the text through the Google Translate API to convert the lecture content into target languages. The final output is structured as JSON containing the segmented transcript and timestamps, which the Node.js server stores in the database. This allows the frontend video player to display interactive, searchable subtitles synchronized with the video playback.

## Microservices and API Design

The system architecture utilizes a microservices approach to isolate resource-intensive AI logic from the high-concurrency web server logic.

The API design generally follows RESTful principles. The Node.js Express server exposes distinct routes organized by resource entities (e.g., `/api/auth`, `/api/classes`, `/api/recordings`). These endpoints parse incoming request bodies, query the MongoDB database utilizing the Mongoose ODM (Object Data Modeling) library, and return standardized JSON responses.

To maintain scalability, synchronous blocking operations within the Node.js environment are strictly avoided. Because Node.js is single-threaded, if it were to process a 10-second face recognition computation, no other users could access the application during those 10 seconds. Therefore, the architecture features dedicated Python FastAPI microservices.

FastAPI is structured around standard Python asynchronous definitions (`async def`). When the Node.js server requires face recognition or translation, it makes an internal HTTP POST request to the FastAPI endpoints. FastAPI receives this payload, processes the machine learning inference, and returns a JSON response. This design ensures that the web server remains highly responsive, easily scaling to handle thousands of concurrent WebSocket connections while delegating heavy CPU or GPU workloads to specialized, separate backend services.

## Docker and Deployment

Docker is utilized to ensure environmental consistency and simplify deployment processes. 

Containerization is a technology that packages an application and all its dependencies—such as libraries, runtime environments, and system tools—into a single, standardized unit called a container. Unlike traditional virtual machines that require a full operating system for each application, containers share the host machine's OS kernel, making them remarkably lightweight, fast to start, and highly efficient.

In this project, Docker is particularly crucial for the Python microservices. Machine learning libraries often depend on complex system-level binaries (like specific C++ compilers or the FFmpeg media processing suite) that are notoriously difficult to configure consistently across different operating systems. By writing a Dockerfile, the exact environment—down to the specific version of Linux and Python dependencies—is explicitly defined. 

During deployment, the Docker demon builds an image based on these instructions. This image is guaranteed to run identically on an Azure cloud server as it does on a local developer's laptop, completely eliminating "it works on my machine" deployment failures.

## Cloud Infrastructure

The application relies on cloud infrastructure, specifically leveraging the Microsoft Azure ecosystem, to achieve high availability and internet-facing deployment.

The architecture separates the hosting of the distinct services. The Node.js core backend is hosted on Render, a PaaS (Platform as a Service) provider that automatically pulls code from the main GitHub branch, builds the Node environment, manages SSL certificates, and exposes the REST API to the public internet securely.

The Python microservices, specifically the voice translation and face recognition engines, are deployed using Azure Container Instances (ACI). The Docker images containing the FastAPI applications and machine learning models are pushed to an Azure Container Registry (a private cloud storage repository for Docker images). ACI then pulls these images and runs them. ACI is ideal for this use case because it provides instant, scalable cloud compute resources without the administrative overhead of managing underlying virtual machines. It ensures that the specific CPU and memory requirements necessary to load the Whisper or InsightFace models into RAM are met reliably in a production environment.

## Data Flow Explanation

The technical data flow of a student joining a class and having their attendance recorded operates through the following steps:

The user navigates to the class URL on the Angular frontend. The Angular router mounts the video room component. The component executes an initialization function that prompts the browser's hardware API to activate the webcam and microphone.

Simultaneously, the component establishes an HTTP connection to the Node.js server to fetch the class details using the unique class ID from the URL parameters. Once the class is validated, the frontend initiates a WebSocket connection via Socket.io to the Node.js server, transmitting a "user-connected" event.

When the user enters the room, the frontend application silently captures an image from the live video feed. This image is transformed into a base64 string and sent as an HTTP POST payload to the Node.js Gateway.

The Gateway immediately proxies this payload to the Python FastAPI microservice. The Python service decodes the image, runs the facial detection and embedding extraction models, and queries the user's previously stored embeddings. It calculates a similarity score and answers the Gateway with a strict boolean regarding verification success.

Upon receiving a positive verification from the Python service, the Node.js Gateway updates the MongoDB database, inserting the student's unique identifier into the class's attendance array along with the current server timestamp. It then resolves the initial verification request back to the Angular client. Finally, the student's local WebRTC client negotiates a direct peer-to-peer media connection with the professor's client, and live video transmission begins.

## Interview Preparation

### Explain how WebRTC differs from traditional streaming.
Traditional streaming methods, such as HLS or DASH utilized by platforms like YouTube, rely on a client-server architecture. The broadcaster sends the media feed to a central server, which then processes, chunks, and distributes the feed to viewers over HTTP. This process inherently introduces several seconds of latency. WebRTC, conversely, is built for interactive, real-time communication. It utilizes a peer-to-peer architecture transmitting data over UDP (User Datagram Protocol). By bypassing the central server entirely and prioritizing speed over guaranteed packet delivery, WebRTC achieves sub-second latency required for live, synchronous conversations.

### What is the role of a Signaling Server in a P2P connection?
While WebRTC transmits media directly between peers, those peers cannot find each other on the internet without initial assistance. The signaling server (in this project, facilitated by Node.js and PeerJS) acts as the initial matcher. Its sole responsibility is to pass metadata between the two clients before the direct connection begins. This metadata includes SDP (Session Description Protocol) objects outlining media capabilities, and ICE (Interactive Connectivity Establishment) candidates denoting public IP addresses and port numbers required to traverse NAT firewalls.

### Why use FastAPI for the AI processing instead of integrating it directly into Node.js?
Node.js operates on a single-threaded, event-driven architecture optimized for highly concurrent I/O operations, making it excellent for web servers and database routing. However, it blocks the main thread when executing prolonged, CPU-intensive tasks like generating facial embeddings or running audio models. Integrating Python libraries directly into standard Node.js processes would cause the entire application to hang during computation, dropping WebSocket connections and failing standard API requests. FastAPI, inherently asynchronous and built in Python (the native ecosystem for data science and AI libraries), allows these heavy workloads to execute independently as a standalone microservice, ensuring the main gateway remains highly responsive.

### What problem does Docker solve in this application?
The application relies heavily on complex environmental dependencies, particularly for the voice translation service which requires specific versions of Python, FastAPI, and system-level installations like the FFmpeg binary suite. Without Docker, deploying this application to a cloud server would require manually installing and configuring these exact versions on the host operating system, leading to high failure rates and "it works on my machine" discrepancies. Docker solves this by containerizing the application—packaging the code, runtime, system tools, and libraries into a single, immutable image. This ensures guaranteed consistency across the entire development and deployment lifecycle, regardless of the underlying host machine.

### Explain the difference between synchronous HTTP and WebSocket communication as used in the project.
The project utilizes synchronous HTTP requests for standard transactional operations, such as logging in, fetching class schedules, or submitting a biometric frame for verification. In HTTP, the client initiates a request, the server processes it, returns a response, and the connection is immediately closed. This is stateless and efficient for singular data exchanges. 
Conversely, WebSockets are utilized for the live chat functionality. A WebSocket connection begins as an HTTP request but is immediately upgraded to a persistent, full-duplex TCP connection. The connection remains open indefinitely. This allows the server to proactively push data (like a new chat message) instantly to the client without the client having to continuously poll or request system updates.

### Explain how the facial recognition attendance system safeguards against errors.
The attendance system relies on a multi-stage pipeline utilizing the InsightFace framework. When the frame is passed to the AI microservice, it first utilizes a specific detection architecture to locate a bounded box representing a human face, ensuring that random environmental patterns are not processed. Once a face is isolated, a secondary feature extraction model translates the facial geometry into a high-dimensional mathematical vector (embedding). Security and accuracy are maintained by relying on cosine similarity scoring between the live vector and the pre-enrolled database vector. Because the matching relies on strict mathematical thresholds calculated on deep geometric features, the system is highly resilient to variations in lighting, angle, or minor changes in the user's appearance.
