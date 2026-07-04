-- ============================================
-- PROYECTO SEMANAL: Ranking con Window Functions
-- Semana 14 — Window Functions (ROW_NUMBER, RANK, DENSE_RANK)
-- Dominio: INMOBILIARIA
-- PostgreSQL 16
-- ============================================

-- Adaptación del esquema genérico a bienes raíces:
--   categories → tipos_propiedad (Apartamento, Casa, Local, etc.)
--   items      → propiedades (con su precio de venta)

DROP TABLE IF EXISTS propiedades CASCADE;
DROP TABLE IF EXISTS tipos_propiedad CASCADE;

CREATE TABLE tipos_propiedad (
    id   SERIAL PRIMARY KEY,
    name TEXT   NOT NULL
);

CREATE TABLE propiedades (
    id          SERIAL         PRIMARY KEY,
    name        TEXT           NOT NULL,        -- nombre/referencia de la propiedad
    value       NUMERIC(12, 2) NOT NULL,         -- precio de venta
    category_id INT            REFERENCES tipos_propiedad (id),
    is_active   BOOLEAN        NOT NULL DEFAULT TRUE
);

-- ============================================
-- DATOS: 5 tipos de propiedad
-- ============================================
INSERT INTO tipos_propiedad (name) VALUES
    ('Apartamento'),      -- id 1
    ('Casa'),             -- id 2
    ('Local Comercial'),  -- id 3
    ('Oficina'),          -- id 4
    ('Terreno');          -- id 5

-- ============================================
-- DATOS: 200 propiedades generadas con generate_series
-- ============================================
-- Se usa un arreglo de 20 precios fijos que se repiten en ciclo.
-- Esto GARANTIZA empates (mismo precio) dentro de cada categoría,
-- que es justo lo que necesitamos para que RANK() y DENSE_RANK()
-- se comporten distinto y sea visible en los resultados.

INSERT INTO propiedades (name, value, category_id, is_active)
SELECT
    'Propiedad ' || gs AS name,
    (ARRAY[250000, 280000, 300000, 320000, 350000, 380000, 400000,
           420000, 450000, 480000, 500000, 520000, 550000, 580000,
           600000, 620000, 650000, 680000, 700000, 750000]
    )[1 + (gs % 20)] AS value,
    1 + (gs % 5) AS category_id,   -- reparte entre las 5 categorías
    TRUE
FROM generate_series(1, 200) AS gs;

-- ============================================
-- DATOS: duplicados intencionales por nombre
-- ============================================
-- Simula un error real de captura: la misma propiedad quedó
-- registrada dos veces. Esto es lo que vamos a limpiar en el TODO 1.

INSERT INTO propiedades (name, value, category_id, is_active) VALUES
    ('Casa Vista Verde', 450000, 2, TRUE),
    ('Casa Vista Verde', 450000, 2, TRUE);  -- registro duplicado


-- ============================================
-- TODO 1: Eliminar duplicados con ROW_NUMBER()
-- ============================================
-- Problema: "Casa Vista Verde" está repetida dos veces con el
-- mismo precio. Usamos ROW_NUMBER() para numerar las filas
-- dentro de cada grupo de "name" (PARTITION BY name), ordenando
-- por id. Luego, en el SELECT exterior, nos quedamos solo con
-- rn = 1, es decir, la primera aparición de cada nombre.

WITH deduplicado AS (
    SELECT
        id,
        name,
        value,
        category_id,
        ROW_NUMBER() OVER (
            PARTITION BY name
            ORDER BY id
        ) AS rn
    FROM propiedades
)
SELECT id, name, value, category_id
FROM deduplicado
WHERE rn = 1
ORDER BY id;


-- ============================================
-- TODO 2: RANK() por tipo de propiedad
-- ============================================
-- Clasifica las propiedades por precio (value), DENTRO de cada
-- tipo (PARTITION BY category_id). Usamos RANK() a propósito
-- (en vez de DENSE_RANK) para que se note cómo, tras un empate,
-- el siguiente número se SALTA. Gracias a los precios repetidos
-- del generate_series, vas a ver varios empates reales aquí.

SELECT
    p.name,
    p.value,
    t.name AS tipo_propiedad,
    RANK() OVER (
        PARTITION BY p.category_id
        ORDER BY p.value DESC
    ) AS rnk
FROM propiedades p
INNER JOIN tipos_propiedad t ON p.category_id = t.id
ORDER BY p.category_id, rnk;


-- ============================================
-- TODO 3: Top-2 propiedades más caras por tipo
-- ============================================
-- Usamos DENSE_RANK() (no RANK) porque si dos propiedades
-- empatan en el precio más alto, ambas deben contar como el
-- "puesto 1", sin que eso salte el puesto 2. El CTE calcula el
-- ranking, y el SELECT exterior filtra dense_rnk <= 2.

WITH ranked_propiedades AS (
    SELECT
        p.name,
        p.value,
        p.category_id,
        DENSE_RANK() OVER (
            PARTITION BY p.category_id
            ORDER BY p.value DESC
        ) AS dense_rnk
    FROM propiedades p
)
SELECT
    r.name,
    r.value,
    t.name AS tipo_propiedad,
    r.dense_rnk
FROM ranked_propiedades r
INNER JOIN tipos_propiedad t ON r.category_id = t.id
WHERE r.dense_rnk <= 2
ORDER BY r.category_id, r.dense_rnk;