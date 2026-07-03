-- ============================================
-- PROYECTO SEMANAL: NULL y Constraints
-- Semana 07 — NOT NULL, UNIQUE, CHECK, FK
-- Dominio: Inmobiliaria
-- ============================================

-- NOTA: PRAGMA foreign_keys = ON es sintaxis de SQLite.
-- En PostgreSQL las foreign keys están activas por defecto,
-- no se necesita este comando.

-- ============================================
-- PARTE 1: ESQUEMA CON CONSTRAINTS
-- ============================================

DROP TABLE IF EXISTS inmuebles_demo;
DROP TABLE IF EXISTS categorias_inmueble;

-- Tabla de categorías: tipos de inmueble
CREATE TABLE categorias_inmueble (
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL UNIQUE
);

-- Tabla principal: inmuebles, con todos los constraints
CREATE TABLE inmuebles_demo (
    id            INTEGER PRIMARY KEY,
    name          TEXT    NOT NULL,
    codigo        TEXT    NOT NULL UNIQUE,             -- UNIQUE: código interno del inmueble
    precio        NUMERIC NOT NULL CHECK (precio > 0), -- CHECK: precio debe ser positivo
    estado        TEXT    NOT NULL DEFAULT 'disponible', -- DEFAULT: estado por defecto
    area_m2       NUMERIC,                              -- opcional, puede ser NULL
    category_id   INTEGER NOT NULL
        REFERENCES categorias_inmueble(id) ON DELETE RESTRICT
);


-- ============================================
-- PARTE 2: DATOS DE PRUEBA
-- ============================================

INSERT INTO categorias_inmueble (id, name) VALUES
    (1, 'Casa'),
    (2, 'Apartamento'),
    (3, 'Local Comercial');

INSERT INTO inmuebles_demo (id, name, codigo, precio, estado, area_m2, category_id) VALUES
    (1, 'Casa Los Alpes',        'INM-001', 350000000, 'disponible', 120.5, 1),
    (2, 'Apto Torre Norte',      'INM-002', 210000000, 'disponible', 65.0,  2),
    (3, 'Local Centro',          'INM-003', 180000000, 'vendido',    NULL,  3),
    (4, 'Casa Campestre',        'INM-004', 420000000, 'disponible', NULL,  1),
    (5, 'Apto Vista Verde',      'INM-005', 195000000, 'reservado',  58.0,  2),
    (6, 'Local Zona Rosa',       'INM-006', 275000000, 'disponible', NULL,  3);


-- ============================================
-- PARTE 3: CONSULTAS CON NULL
-- ============================================

-- Inmuebles sin área registrada (valor desconocido)
SELECT id, name
FROM   inmuebles_demo
WHERE  area_m2 IS NULL;

-- Todos los inmuebles, reemplazando NULL en área por un texto claro
SELECT
    name,
    COALESCE(area_m2::text, 'Sin área registrada') AS area_display
FROM inmuebles_demo;



SELECT COUNT(*) AS con_null_area
FROM propiedades
WHERE area_m2 IS NULL;



-- Confirma que existen las 2 tablas nuevas
SELECT table_name
FROM information_schema.tables
WHERE table_name IN ('categorias_inmueble', 'inmuebles_demo');

-- Confirma que hay 3 categorías y 6 inmuebles
SELECT (SELECT COUNT(*) FROM categorias_inmueble) AS total_categorias,
       (SELECT COUNT(*) FROM inmuebles_demo) AS total_inmuebles;

-- Confirma que el CHECK funciona: esto DEBE dar error (precio negativo)
-- (ejecútalo aparte, solo para comprobar que SÍ falla)
INSERT INTO inmuebles_demo (id, name, codigo, precio, category_id)
VALUES (99, 'Prueba Check', 'INM-999', -100, 1);

-- Confirma que hay NULLs reales en area_m2 (deben ser al menos 3, según pide el proyecto)
SELECT COUNT(*) AS con_area_null
FROM inmuebles_demo
WHERE area_m2 IS NULL;

-- Confirma que COALESCE funciona
SELECT name, COALESCE(area_m2::text, 'Sin área registrada') AS area_display
FROM inmuebles_demo;