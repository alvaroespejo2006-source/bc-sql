-- ============================================
-- PROYECTO SEMANAL: CTEs y CASE WHEN en tu dominio
-- Semana 12 — Common Table Expressions + Condicionales
-- Dominio: Inmobiliaria
-- Tabla principal: propiedades | Secundaria: contratos
-- ============================================

-- ============================================
-- CONSULTA 1: CTE simple + CASE WHEN de clasificación
-- Clasifica cada propiedad según su precio en 3 bandas,
-- e incluye cuántos contratos tiene asociados
-- ============================================
WITH propiedades_con_actividad AS (
    SELECT
        p.id_propiedad,
        p.direccion,
        p.precio,
        p.id_tipo,
        COUNT(c.id_contrato) AS total_contratos
    FROM propiedades p
    LEFT JOIN contratos c ON c.id_propiedad = p.id_propiedad
    GROUP BY p.id_propiedad, p.direccion, p.precio, p.id_tipo
)
SELECT
    direccion,
    precio,
    total_contratos,
    CASE
        WHEN precio >= 350000000 THEN 'Premium'
        WHEN precio >= 180000000 THEN 'Estándar'
        ELSE                          'Económico'
    END AS price_band
FROM propiedades_con_actividad
ORDER BY precio DESC;


-- ============================================
-- CONSULTA 2: Dos CTEs encadenados
-- Primer CTE: monto total de contratos por tipo de propiedad
-- Segundo CTE: tipos de propiedad por encima del promedio
-- ============================================
WITH ventas_por_tipo AS (
    SELECT
        p.id_tipo,
        SUM(c.monto_final) AS total_vendido
    FROM propiedades p
    INNER JOIN contratos c ON c.id_propiedad = p.id_propiedad
    GROUP BY p.id_tipo
),
tipos_top AS (
    SELECT id_tipo
    FROM ventas_por_tipo
    WHERE total_vendido > (SELECT AVG(total_vendido) FROM ventas_por_tipo)
)
SELECT
    vt.id_tipo,
    vt.total_vendido
FROM ventas_por_tipo vt
WHERE vt.id_tipo IN (SELECT id_tipo FROM tipos_top)
ORDER BY vt.total_vendido DESC;


-- ============================================
-- CONSULTA 3: CTE + COUNT condicional por banda
-- Por tipo de propiedad, cuenta cuántas hay en cada banda de precio
-- ============================================
WITH clasificados AS (
    SELECT
        direccion,
        id_tipo,
        precio,
        CASE
            WHEN precio >= 350000000 THEN 'Premium'
            WHEN precio >= 180000000 THEN 'Estándar'
            ELSE                          'Económico'
        END AS price_band
    FROM propiedades
)
SELECT
    id_tipo,
    COUNT(CASE WHEN price_band = 'Premium'   THEN 1 END) AS premium_count,
    COUNT(CASE WHEN price_band = 'Estándar'  THEN 1 END) AS estandar_count,
    COUNT(CASE WHEN price_band = 'Económico' THEN 1 END) AS economico_count
FROM clasificados
GROUP BY id_tipo
ORDER BY id_tipo;