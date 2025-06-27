-- Tabla 1: jugadores
CREATE TABLE jugadores (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    nombre TEXT NOT NULL,
    puntaje INTEGER
);

-- Tabla 2: leyes
CREATE TABLE leyes (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    ley TEXT,
    correcta INTEGER,
    equivocada INTEGER
);

-- Tabla 3: tiempo
CREATE TABLE tiempo (
    segundos INTEGER
);

-- Tabla 4: npc
CREATE TABLE npc (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    frase TEXT,
    correcta INTEGER,
    equivocada INTEGER
);