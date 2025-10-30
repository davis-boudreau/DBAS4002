CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Event (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL REFERENCES Category(category_id) ON DELETE CASCADE,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    priority INT DEFAULT 1,
    description TEXT DEFAULT '',
    location VARCHAR(255) DEFAULT '',
    organizer VARCHAR(100) DEFAULT ''
);

CREATE TABLE Participant (
    participant_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    registered_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Registration (
    registration_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES Event(event_id) ON DELETE CASCADE,
    participant_id INT NOT NULL REFERENCES Participant(participant_id) ON DELETE CASCADE,
    registered_on TIMESTAMP DEFAULT NOW(),
    payment_status VARCHAR(20) DEFAULT 'Pending',
    UNIQUE (event_id, participant_id)
);