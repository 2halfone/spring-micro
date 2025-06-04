-- SpringMon Database Initialization
-- Creates schema for authentication and user management system

-- Create springmon_user database if it doesn't exist
-- Note: The main 'springmon' database is created automatically via POSTGRES_DB

-- First, create the springmon_user database
CREATE DATABASE springmon_user;

-- Connect to the main springmon database for auth tables
\c springmon;

-- Tabella utenti
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT true,
    account_non_expired BOOLEAN DEFAULT true,
    account_non_locked BOOLEAN DEFAULT true,
    credentials_non_expired BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Tabella ruoli
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabella associazione utenti-ruoli
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Tabella refresh tokens per JWT
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    expiry_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserimento ruoli predefiniti
INSERT INTO roles (name, description) VALUES 
('ROLE_USER', 'Standard user role'),
('ROLE_ADMIN', 'Administrator role'),
('ROLE_MODERATOR', 'Moderator role')
ON CONFLICT (name) DO NOTHING;

-- Creazione utente admin predefinito (password: admin123)
-- Password hash per 'admin123' usando BCrypt
INSERT INTO users (username, email, password_hash) VALUES 
('admin', 'admin@springmon.local', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVMIlW')
ON CONFLICT (username) DO NOTHING;

-- Assegnazione ruolo admin all'utente admin
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id 
FROM users u, roles r 
WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN'
ON CONFLICT DO NOTHING;

-- Indici per performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expiry ON refresh_tokens(expiry_date);

-- Trigger per aggiornamento automatico timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Commenti sulla struttura
COMMENT ON TABLE users IS 'Tabella utenti per autenticazione SpringMon';
COMMENT ON TABLE roles IS 'Ruoli di sistema';
COMMENT ON TABLE user_roles IS 'Associazione molti-a-molti utenti-ruoli';
COMMENT ON TABLE refresh_tokens IS 'Token di refresh per JWT';

-- Pulizia automatica token scaduti (da schedulare)
-- DELETE FROM refresh_tokens WHERE expiry_date < CURRENT_TIMESTAMP;

-- ==================================================
-- CONFIGURAZIONE DATABASE USER SERVICE
-- ==================================================

-- Connessione al database springmon_user per user service
\c springmon_user;

-- Creazione schema utenti per user service (semplificato)
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creazione funzione aggiornamento timestamp per user service
CREATE OR REPLACE FUNCTION update_updated_at_column_user()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger per aggiornamento automatico timestamp su user service
CREATE OR REPLACE TRIGGER update_users_updated_at_user
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column_user();

-- Indici per performance su user service
CREATE INDEX IF NOT EXISTS idx_users_username_user ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email_user ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active_user ON users(is_active);

-- Dati di test per user service
INSERT INTO users (username, email, first_name, last_name) VALUES 
('testuser', 'test@springmon.local', 'Test', 'User'),
('admin_user', 'admin@springmon.local', 'Admin', 'User')
ON CONFLICT (username) DO NOTHING;

-- Commenti user service
COMMENT ON TABLE users IS 'Tabella utenti per gestione dati SpringMon User Service';

-- Grant privilegi al database user service
GRANT ALL PRIVILEGES ON DATABASE springmon_user TO springmon_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO springmon_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO springmon_user;
