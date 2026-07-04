# Smart Surveillance: AI-Powered After-Hours Intrusion & Suspicious Behavior Detection

An intelligent, multi-threaded computer vision security system designed for capstone research and enterprise environments. The system uses **YOLOv8** to monitor video feeds (RTSP/Webcam) for unauthorized human presence during after-hours, logs telemetry to a **PostgreSQL** database, dispatches rich email alerts containing snapshot attachments and interactive action buttons, and serves a modern real-time **Flask** dashboard for threat confirmation.

---

## 🏗️ System Architecture

This project is built using a **decoupled, multi-threaded architecture** to ensure performance and reliability. By separating the real-time AI processing stream from the dashboard web server, the video capture and inference processes run smoothly at high FPS without causing lag or freezing the web dashboard.

```mermaid
graph TD
    %% Define Nodes
    Cam[RTSP Camera / Webcam] -->|Frame Stream| Obs[Live Observer Thread: live_observer.py]
    
    subgraph AI Engine (Background Process)
        Obs -->|1. Run YOLOv8 Detection| YOLO[YOLOv8 Engine]
        Obs -->|2. Check Rules| Rule{Is After-Hours?}
        Obs -->|3. Capture Frame| Snap[Save Snapshot Image]
    end
    
    Rule -->|Yes & Confidence >= Thresh| LogDB[(PostgreSQL Database)]
    Rule -->|Yes & Confidence >= Thresh| Email[SMTP Email Service]
    
    subgraph Web Dashboard (Flask Application)
        DBAccess[Database Connection] -->|Query Recent Logs| App[Flask Server: app.py]
        App -->|API Endpoints| UI[Web Dashboard UI: dashboard.html]
        Owner[Owner Email Client] -->|Click Action URL| App
    end
    
    LogDB -->|Read/Write Logs| DBAccess
    Email -->|Send Alert Image & URLs| Owner
    
    %% Styling
    style Cam fill:#d4ebf2,stroke:#333,stroke-width:2px;
    style Obs fill:#fce5cd,stroke:#333,stroke-width:2px;
    style YOLO fill:#fce5cd,stroke:#333,stroke-width:1px;
    style LogDB fill:#d9ead3,stroke:#333,stroke-width:2px;
    style App fill:#fff2cc,stroke:#333,stroke-width:2px;
    style UI fill:#fff2cc,stroke:#333,stroke-width:1px;
    style Email fill:#ead1dc,stroke:#333,stroke-width:2px;
```

---

## ✨ Key Features

*   **Continuous AI Live Monitoring:** Connects to an RTSP camera stream or local webcam and processes frames using YOLOv8 person detection.
*   **Time-Window Security Rules:** Reduces false alarms by running intrusion checks only during defined **after-hours** (e.g., 10 PM to 8 AM).
*   **Decoupled Multi-Threading:** The AI live observer loop and Flask dashboard web server run as independent processes communicating asynchronously via PostgreSQL.
*   **Intelligent Alert Spam Cooldown:** Incorporates a configurable cooldown timer (default: 60s) to prevent overwhelming the owner with repetitive emails during a single intrusion event.
*   **Interactive Response Email Notifications:** Sends high-priority emails containing:
    *   The exact timestamp and camera location of the intrusion.
    *   An attached JPEG snapshot of the intruder.
    *   **Actionable confirmation buttons:** `YES - Call Police` or `NO - False Alarm` pointing directly to Webhook endpoints.
*   **Real-time Admin Dashboard:** A responsive Bootstrap-based dashboard showing live metrics, system status, database health, and a feed of recent alerts complete with snapshot rendering.
*   **Contextual Police Contact Directory:** Resolves the appropriate police station contact number based on the camera location.

---

## 🗄️ Database Design

The PostgreSQL database maintains a single core ledger `intrusion_logs` that records each security event.

### Schema (`database/schema.sql`)
```sql
CREATE TABLE intrusion_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(255) NOT NULL,
    confidence NUMERIC(5, 4) NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
    snapshot_path VARCHAR(512) NOT NULL
);

-- Index for instant lookup of recent records on the dashboard
CREATE INDEX idx_intrusion_logs_timestamp ON intrusion_logs (timestamp DESC);
```

---

## 📂 Project Directory Structure

```bash
smart-surveillance/
│
├── Smart-Surveillance-main/
│   ├── app.py                  # Flask Dashboard Server & Web API Webhooks
│   ├── live_observer.py         # Background AI Process (OpenCV + YOLO Inference)
│   ├── config.py                # Configuration Loader (Loads .env configs)
│   ├── .env                     # Environment Variables (Ignored by Git)
│   ├── requirements.txt         # Project dependencies
│   │
│   ├── Architecture/            # Architecture blueprints & design choices documentation
│   │   ├── Endpoints.md
│   │   ├── Project_Architecture.md
│   │   ├── Reason-For-chosen.md
│   │   └── structure.md
│   │
│   ├── database/
│   │   ├── schema.sql           # PostgreSQL table definitions
│   │   └── seed.sql             # SQL seed script to populate mock alerts
│   │
│   ├── templates/
│   │   └── dashboard.html       # Frontend HTML/JS dashboard
│   │
│   ├── static/
│   │   └── snapshots/           # Directory where intrusion screenshots are saved
│   │
│   ├── models/
│   │   └── best.pt              # YOLO object detection weights (person class detector)
│   │
│   └── logs/
│       └── system.log           # Standardized application execution log
│
└── README.md                    # Main Repository Documentation (This file)
```

---

## 🚀 Installation & Setup Guide

### 1. Prerequisites
Ensure you have the following installed on your host system:
*   Python 3.8 or higher
*   PostgreSQL Database Server
*   A webcam or access to an RTSP IP camera feed

### 2. Clone the Repository & Configure Environment
Navigate to the project folder and create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

Install the dependencies:
```bash
pip install -r requirements.txt
```

### 3. Database Initialization
Create a new database named `smart_surveillance` in PostgreSQL. Then, run the schema and seed files to initialize the tables and populate sample alerts:
```bash
# Using psql terminal tool
psql -U postgres -d smart_surveillance -f database/schema.sql
psql -U postgres -d smart_surveillance -f database/seed.sql
```

### 4. Create the Environment File
Create a `.env` file in the root of `Smart-Surveillance-main/` folder and add your credentials:
```ini
# PostgreSQL Connection Configuration
DB_NAME=smart_surveillance
DB_USER=your_postgres_username
DB_PASSWORD=your_postgres_password
DB_HOST=127.0.0.1
DB_PORT=5432

# Gmail SMTP Configuration for Alerts
SENDER_EMAIL=your_alerts_email@gmail.com
RECEIVER_EMAIL=your_personal_email@gmail.com
# Use an "App Password" generated in your Google Account Settings (not your raw password)
EMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx

# Server Base URL (Used for generating email response links)
BASE_URL=http://127.0.0.1:5000
```

---

## 🏃 Running the Application

For a fully operational system, launch both systems in separate terminals or background jobs.

### Terminal 1: Start the Web Dashboard
```bash
cd Smart-Surveillance-main
python app.py
```
*   The dashboard will boot on [http://127.0.0.1:5000/](http://127.0.0.1:5000/).
*   You can visit this page immediately to view loaded database seed records.

### Terminal 2: Start the AI Live Observer
```bash
cd Smart-Surveillance-main
python live_observer.py
```
*   The observer will load your custom model weight file (`models/best.pt`).
*   It connects to camera channel `0` (default webcam) and begins evaluating frames.
*   Upon detecting a person **after-hours**, it triggers a database entry, saves a snapshot to `static/snapshots/`, and dispatches an email alert.

---

## 📡 API Reference & Webhooks

The Flask web application exposes the following endpoints:

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/` | `GET` | Serves the HTML Admin Dashboard |
| `/api/alerts` | `GET` | Fetches the 20 most recent intrusion records from the DB |
| `/api/alerts/<id>` | `GET` | Fetches a single intrusion record details by ID |
| `/api/response` | `GET` | Action webhook clicked by the owner from their email alert. Accepts `status` (`yes`/`no`) and `location` |
| `/api/police/<location>`| `GET` | Returns local police contact station name and phone number for the location |
| `/health` | `GET` | System health check (validates PostgreSQL database connectivity) |

### Interactive Email Response Flow:
When an alert is received:
1. Clicking **"YES - Call Police"** fires `/api/response?status=yes&location=Back Gate`. The response alerts the operator with the station phone number (e.g. `+8801711111111`) and records owner verification.
2. Clicking **"NO - False Alarm"** fires `/api/response?status=no`. The incident is flagged as resolved and marked as a false alarm in system logs.

---

## 📈 Developer Roadmap & Research Extensions

To scale this system into a publication-quality capstone project or commercial product, we recommend implementing the following modules:

1.  **Restricted Region of Interest (ROI):** Define coordinate polygons on camera streams. Trigger intrusions only if the bounding box overlaps with the custom ROI mask.
2.  **Night-Time Image Enhancement:** Integrate contrast-limited adaptive histogram equalization (CLAHE) or zero-shot low-light enhancement models (like Zero-DCE) to improve YOLO accuracy under poor illumination.
3.  **Multi-Camera Thread Pool:** Run multiple instances of `live_observer.py` in a thread pool, each listening to a different RTSP stream URL, feeding a consolidated database schema.
4.  **DeepSORT/ByteTrack Integration:** Track unique individuals over frames to compute speed, trajectory, and distinguish between quick pass-throughs and suspicious lingering behaviors.