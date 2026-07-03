-- ============================================
-- PROYECTO SEMANAL: Funciones de Agregación
-- Semana 06 — COUNT, SUM, AVG, GROUP BY, HAVING
-- Dominio: Inmobiliaria
-- ============================================

-- ============================================
-- REPORTE 1: Totales globales
-- ============================================
SELECT
    COUNT(*)                        AS total_propiedades,
    SUM(precio)                     AS valor_total_inventario,
    ROUND(AVG(precio)::numeric, 2)  AS precio_promedio
FROM propiedades;


-- ============================================
-- REPORTE 2: Extremos
-- ============================================
SELECT
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo
FROM propiedades;


-- ============================================
-- REPORTE 3: Subtotales por tipo de propiedad
-- ============================================
SELECT
    tp.nombre_tipo,
    COUNT(*)                         AS total,
    ROUND(AVG(p.precio)::numeric, 2) AS promedio
FROM propiedades p
JOIN tipos_propiedad tp ON p.id_tipo = tp.id_tipo
GROUP BY tp.nombre_tipo
ORDER BY total DESC;


-- ============================================
-- REPORTE 4: Tipos de propiedad con oferta amplia
-- ============================================
-- Filtro de negocio: solo tipos con más de 3 unidades disponibles
-- (indica un segmento con inventario suficiente para analizar tendencias)
SELECT
    tp.nombre_tipo,
    COUNT(*) AS total
FROM propiedades p
JOIN tipos_propiedad tp ON p.id_tipo = tp.id_tipo
GROUP BY tp.nombre_tipo
HAVING COUNT(*) > 3;