-- ============================================
-- PROYECTO SEMANAL: Ranking con Window Functions
-- Semana 14 — Window Functions (ROW_NUMBER, RANK, DENSE_RANK)
-- Dominio: INMOBILIARIA
-- PostgreSQL 16
-- ============================================

DROP TABLE IF EXISTS propiedades CASCADE;
DROP TABLE IF EXISTS tipos_propiedad CASCADE;

CREATE TABLE tipos_propiedad (
    id   SERIAL PRIMARY KEY,
    name TEXT   NOT NULL
);

CREATE TABLE propiedades (
    id          SERIAL         PRIMARY KEY,
    name        TEXT           NOT NULL,
    value       NUMERIC(12, 2) NOT NULL,
    category_id INT            REFERENCES tipos_propiedad (id),
    is_active   BOOLEAN        NOT NULL DEFAULT TRUE
);

-- ============================================
-- DATOS: 5 tipos de propiedad
-- ============================================
INSERT INTO tipos_propiedad (name) VALUES
    ('Apartamento'),
    ('Casa'),
    ('Local Comercial'),
    ('Oficina'),
    ('Terreno');

-- ============================================
-- DATOS: 200 propiedades generadas con generate_series
-- ============================================
INSERT INTO propiedades (name, value, category_id, is_active)
SELECT
    'Propiedad ' || gs AS name,
    (ARRAY[250000, 280000, 300000, 320000, 350000, 380000, 400000,
           420000, 450000, 480000, 500000, 520000, 550000, 580000,
           600000, 620000, 650000, 680000, 700000, 750000]
    )[1 + (gs % 20)] AS value,
    1 + (gs % 5) AS category_id,
    TRUE
FROM generate_series(1, 200) AS gs;

-- ============================================
-- DATOS: duplicados intencionales por nombre
-- ============================================
INSERT INTO propiedades (name, value, category_id, is_active) VALUES
    ('Casa Vista Verde', 450000, 2, TRUE),
    ('Casa Vista Verde', 450000, 2, TRUE);


-- ============================================
-- TODO 1: Eliminar duplicados con ROW_NUMBER()
-- ============================================
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