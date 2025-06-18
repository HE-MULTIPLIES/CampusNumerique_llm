-- The postgres image automatically creates the POSTGRES_USER with POSTGRES_PASSWORD
-- So we don't need to create it manually

-- Create n8n database if it doesn't exist
SELECT 'CREATE DATABASE n8n'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n')\gexec

-- Connect to n8n database and set up
\c n8n;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Grant privileges to n8n database
GRANT ALL PRIVILEGES ON DATABASE n8n TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO CURRENT_USER;
