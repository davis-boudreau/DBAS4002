-- Base schema (Weeks 1–2 foundation)
-- Create Category table

CREATE TABLE IF NOT EXISTS Category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Event table
CREATE TABLE IF NOT EXISTS Event (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    priority INT DEFAULT 1,
    description TEXT,
    location VARCHAR(255),
    organizer VARCHAR(100),
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE
);