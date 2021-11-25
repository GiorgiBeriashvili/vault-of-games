CREATE TABLE IF NOT EXISTS users
(
    id         TEXT
        CONSTRAINT users_pk
            PRIMARY KEY,
    username   TEXT NOT NULL UNIQUE,
    password   TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS users_id_index
    ON users (id);

CREATE TABLE IF NOT EXISTS games
(
    id         TEXT
        CONSTRAINT games_pk
            PRIMARY KEY,
    user_id    TEXT NOT NULL,
    title      TEXT NOT NULL,
    image_url  TEXT,
    status     TEXT,
    rating     INTEGER,
    note       TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX IF NOT EXISTS games_id_index
    ON games (id);

CREATE TABLE IF NOT EXISTS categories
(
    id         TEXT
        CONSTRAINT categories_pk
            PRIMARY KEY,
    name       TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE (name)
);

CREATE UNIQUE INDEX IF NOT EXISTS categories_id_index
    ON categories (id);

CREATE TABLE IF NOT EXISTS games_categories
(
    id          INTEGER
        CONSTRAINT games_categories_pk
            PRIMARY KEY AUTOINCREMENT,
    game_id     TEXT NOT NULL,
    category_id TEXT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP,
    FOREIGN KEY (game_id)
        REFERENCES games (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (category_id)
        REFERENCES categories (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

CREATE UNIQUE INDEX IF NOT EXISTS games_categories_id_index
    ON games_categories (id);
