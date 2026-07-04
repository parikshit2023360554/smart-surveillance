-- ==================================================
-- Smart Surveillance - Database Schema
-- Table structure for storing intrusion events
-- ==================================================

-- Drop table if exists to allow clean re-initialization
DROP TABLE IF EXISTS intrusion_logs CASCADE;

CREATE TABLE intrusion_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(255) NOT NULL,
    confidence NUMERIC(5, 4) NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
    snapshot_path VARCHAR(512) NOT NULL
);

-- Index on timestamp for faster dashboard queries (ORDER BY timestamp DESC)
CREATE INDEX idx_intrusion_logs_timestamp ON intrusion_logs (timestamp DESC);
