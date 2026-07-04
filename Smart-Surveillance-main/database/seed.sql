-- ==================================================
-- Smart Surveillance - Database Seed Data
-- Mock entries for testing the dashboard UI
-- ==================================================

-- Truncate existing logs
TRUNCATE TABLE intrusion_logs RESTART IDENTITY;

-- Insert sample events
INSERT INTO intrusion_logs (timestamp, location, confidence, snapshot_path)
VALUES
    (
        NOW() - INTERVAL '15 minutes',
        'Warehouse Main Entrance',
        0.9421,
        'static/snapshots/intruder_sample.jpg'
    ),
    (
        NOW() - INTERVAL '45 minutes',
        'Back Gate',
        0.8753,
        'static/snapshots/intruder_sample.jpg'
    ),
    (
        NOW() - INTERVAL '2 hours',
        'Warehouse Entrance',
        0.9102,
        'static/snapshots/intruder_sample.jpg'
    ),
    (
        NOW() - INTERVAL '5 hours',
        'Main Lobby',
        0.9584,
        'static/snapshots/intruder_sample.jpg'
    );
