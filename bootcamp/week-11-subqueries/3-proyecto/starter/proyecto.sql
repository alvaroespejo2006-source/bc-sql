-- ============================================
-- PROYECTO SEMANAL: Subqueries en tu dominio
-- Semana 11 — Subqueries (escalar, IN, EXISTS, FROM)
-- Dominio: Inmobiliaria
-- Tabla principal: propiedades (80 filas) | Secundaria: contratos (40 filas)
-- ============================================

-- ============================================
-- CONSULTA 1: Subquery escalar en WHERE
-- Propiedades cuyo precio supera el promedio de su propio tipo
-- ============================================
SELECT
    p.direccion,
    p.precio,
    p.id_tipo
FROM propiedades p
WHERE p.precio > (
    SELECT AVG(p2.precio)
    FROM propiedades p2
    WHERE p2.id_tipo = p.id_tipo
)
ORDER BY p.id_tipo, p.precio DESC;


-- ============================================
-- CONSULTA 2: Subquery escalar en SELECT
-- Muestra el precio promedio global junto a cada propiedad
-- ============================================
SELECT
    direccion,
    precio,
    ROUND((SELECT AVG(precio) FROM propiedades)::numeric, 2) AS precio_promedio_general
FROM propiedades
ORDER BY precio DESC;


-- ============================================
-- CONSULTA 3: NOT EXISTS — propiedades sin actividad
-- Propiedades que NUNCA han tenido un contrato (ni venta ni renta)
-- ============================================
SELECT
    p.direccion AS propiedad_sin_contrato
FROM propiedades p
WHERE NOT EXISTS (
    SELECT 1
    FROM contratos c
    WHERE c.id_propiedad = p.id_propiedad
);


-- ============================================
-- CONSULTA 4: Tabla derivada en FROM
-- Tipos de propiedad con más de 2 contratos registrados
-- ============================================
SELECT
    tipo_stats.id_tipo,
    tipo_stats.total_contratos
FROM (
    SELECT
        p.id_tipo,
        COUNT(c.id_contrato) AS total_contratos
    FROM propiedades p
    LEFT JOIN contratos c ON c.id_propiedad = p.id_propiedad
    GROUP BY p.id_tipo
) AS tipo_stats
WHERE tipo_stats.total_contratos > 2
ORDER BY tipo_stats.total_contratos DESC;