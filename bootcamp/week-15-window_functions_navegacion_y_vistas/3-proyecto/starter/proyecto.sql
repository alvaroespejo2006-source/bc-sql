-- ============================================
-- PROYECTO SEMANAL: Análisis temporal con Window Functions y Vistas
-- Semana 15 — LEAD, LAG, FIRST_VALUE, LAST_VALUE, CREATE VIEW
-- Dominio: INMOBILIARIA
-- PostgreSQL 16
-- ============================================

DROP VIEW  IF EXISTS v_period_analysis CASCADE;
DROP TABLE IF EXISTS ventas_mensuales CASCADE;
DROP TABLE IF EXISTS tipos_propiedad CASCADE;

CREATE TABLE tipos_propiedad (
    id   SERIAL PRIMARY KEY,
    name TEXT   NOT NULL
);

CREATE TABLE ventas_mensuales (
    id          SERIAL         PRIMARY KEY,
    period_date DATE           NOT NULL,
    category_id INT            REFERENCES tipos_propiedad (id),
    value       NUMERIC(12, 2) NOT NULL
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
-- DATOS: 200 filas — 40 meses x 5 categorías
-- ============================================
-- Se usa CAST(... AS NUMERIC) porque SIN() devuelve double
-- precision, y ROUND(valor, decimales) solo acepta ese segundo
-- argumento cuando el primer valor es de tipo numeric.

INSERT INTO ventas_mensuales (period_date, category_id, value)
SELECT
    meses.period_date,
    tp.id AS category_id,
    ROUND(
        CAST(
            (300000 + (tp.id * 40000))
            + (EXTRACT(MONTH FROM meses.period_date)::INT * 5000)
            + (SIN(EXTRACT(EPOCH FROM meses.period_date) / 5000000) * 60000)
            AS NUMERIC
        )
    , 2) AS value
FROM generate_series(
        DATE '2022-01-01',
        DATE '2025-04-01',
        INTERVAL '1 month'
     ) AS meses(period_date)
CROSS JOIN tipos_propiedad tp
ORDER BY tp.id, meses.period_date;


-- ============================================
-- TODO 1: LAG para calcular la variación entre períodos
-- ============================================
SELECT
    period_date,
    category_id,
    value,
    LAG(value, 1, 0) OVER (
        PARTITION BY category_id
        ORDER BY period_date
    )                                                       AS prev_value,
    value - LAG(value, 1, 0) OVER (
        PARTITION BY category_id
        ORDER BY period_date
    )                                                       AS delta
FROM ventas_mensuales
ORDER BY category_id, period_date;


-- ============================================
-- TODO 2: FIRST_VALUE y LAST_VALUE por categoría
-- ============================================
SELECT
    period_date,
    category_id,
    value,
    FIRST_VALUE(value) OVER w AS period_best,
    LAST_VALUE(value)  OVER w AS period_worst
FROM ventas_mensuales
WINDOW w AS (
    PARTITION BY category_id
    ORDER BY value DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
ORDER BY category_id, period_date;


-- ============================================
-- TODO 3: CREATE VIEW — encapsular el análisis
-- ============================================
CREATE OR REPLACE VIEW v_period_analysis AS
SELECT
    period_date,
    category_id,
    value,
    LAG(value, 1, 0) OVER (
        PARTITION BY category_id
        ORDER BY period_date
    ) AS prev_value,
    FIRST_VALUE(value) OVER w AS period_best,
    LAST_VALUE(value)  OVER w AS period_worst
FROM ventas_mensuales
WINDOW w AS (
    PARTITION BY category_id
    ORDER BY value DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);

SELECT *
FROM v_period_analysis
WHERE category_id = 1
ORDER BY period_date;