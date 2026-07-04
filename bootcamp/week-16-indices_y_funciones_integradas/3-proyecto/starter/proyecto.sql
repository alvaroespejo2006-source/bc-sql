-- ============================================
-- PROYECTO SEMANAL: Índices y Consultas Optimizadas
-- Semana 16 — Índices B-tree + Funciones integradas
-- Dominio: INMOBILIARIA
-- PostgreSQL 16
-- ============================================

-- Adaptación del esquema genérico a bienes raíces:
--   categories → tipos_propiedad (Apartamento, Casa, Local, Oficina, Terreno)
--   records    → propiedades (nombre/referencia, descripción, precio, fecha de publicación)

DROP TABLE IF EXISTS propiedades CASCADE;
DROP TABLE IF EXISTS tipos_propiedad CASCADE;

CREATE TABLE tipos_propiedad (
    id   SERIAL PRIMARY KEY,
    name TEXT   NOT NULL
);

CREATE TABLE propiedades (
    id          SERIAL         PRIMARY KEY,
    name        TEXT           NOT NULL,           -- referencia de la propiedad
    description TEXT,
    category_id INT            REFERENCES tipos_propiedad (id),
    price       NUMERIC(12, 2),                    -- precio de venta
    created_at  DATE           NOT NULL DEFAULT CURRENT_DATE  -- fecha de publicación
);

-- ============================================
-- DATOS: 5 tipos de propiedad
-- ============================================
INSERT INTO tipos_propiedad (name) VALUES
    ('Apartamento'),      -- id 1
    ('Casa'),             -- id 2
    ('Local Comercial'),  -- id 3
    ('Oficina'),          -- id 4
    ('Terreno');           -- id 5

-- ============================================
-- DATOS: 200 propiedades generadas con generate_series
-- ============================================
-- generate_series crea 200 números consecutivos (1 a 200). Cada
-- fila se combina con una categoría cíclica (1 al 5), un precio
-- variable, y una fecha de publicación distribuida en los
-- últimos ~5 años (para que AGE/EXTRACT en el TODO 2 tenga
-- variedad real de antigüedades que mostrar).

INSERT INTO propiedades (name, description, category_id, price, created_at)
SELECT
    'Propiedad ' || gs                                   AS name,
    'Descripción de la propiedad número ' || gs          AS description,
    1 + (gs % 5)                                          AS category_id,
    ROUND(
        CAST(200000 + (gs % 50) * 15000 AS NUMERIC)
    , 2)                                                  AS price,
    (DATE '2020-01-01' + ((gs * 9) || ' days')::INTERVAL)::DATE AS created_at
FROM generate_series(1, 200) AS gs;


-- ============================================
-- TODO 1: Crear un índice y verificar con EXPLAIN
-- ============================================
-- Primero vemos el plan SIN índice: con 200 filas, PostgreSQL
-- recorre toda la tabla (Seq Scan) para encontrar las que
-- cumplen category_id = 3. Luego creamos el índice B-tree sobre
-- esa columna, y repetimos el mismo EXPLAIN — con más volumen de
-- datos, ahora sí debería preferir usar el índice (Index Scan o
-- Bitmap Index Scan) en vez de leer todo.

-- Plan ANTES del índice
EXPLAIN
SELECT * FROM propiedades WHERE category_id = 3;

CREATE INDEX idx_propiedades_category_id
    ON propiedades (category_id);

-- Plan DESPUÉS del índice
EXPLAIN
SELECT * FROM propiedades WHERE category_id = 3;


-- ============================================
-- TODO 2: Reporte con funciones de texto y fecha
-- ============================================
-- UPPER() muestra el nombre en mayúsculas. TO_CHAR() formatea
-- la fecha de publicación como texto legible (DD/MM/YYYY).
-- AGE(CURRENT_DATE, created_at) calcula el intervalo desde la
-- publicación hasta hoy, y EXTRACT(YEAR FROM ...) saca solo la
-- parte de años de ese intervalo, dando la antigüedad del anuncio.

SELECT
    UPPER(name)                                            AS name_upper,
    TO_CHAR(created_at, 'DD/MM/YYYY')                      AS created_fmt,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, created_at))::INT  AS years_old
FROM propiedades
ORDER BY years_old DESC;


-- ============================================
-- TODO 3: Reporte numérico con descuento
-- ============================================
-- Calculamos, para cada propiedad: el precio original, el precio
-- con un 15% de descuento (ROUND a 2 decimales para dinero), y el
-- ahorro exacto (la diferencia entre ambos). Ordenamos de mayor a
-- menor precio original.

SELECT
    name,
    price,
    ROUND(price * 0.85, 2)          AS discounted_price,
    ROUND(price - (price * 0.85), 2) AS savings
FROM propiedades
ORDER BY price DESC;