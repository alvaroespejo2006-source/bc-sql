-- ============================================
-- PROYECTO SEMANAL: JOINs aplicados a tu dominio
-- Semana 09 — INNER JOIN y LEFT JOIN
-- ============================================

-- NOTA PARA EL APRENDIZ:
-- Adapta este esquema a tu dominio asignado.
-- Ejemplos de adaptación:
--   Biblioteca  → books, members, loans
--   Farmacia    → medicines, suppliers, sales
--   Gimnasio    → members, trainers, routines
--   Restaurante → dishes, categories, orders
-- NO copies uno de estos ejemplos; usa tu dominio propio.

PRAGMA foreign_keys = ON;

-- ============================================
-- TODO: Renombrar las tablas según tu dominio
-- ============================================

DROP TABLE IF EXISTS child_records;
DROP TABLE IF EXISTS main_items;
DROP TABLE IF EXISTS reference_table;

-- Tabla de referencia (categorías, ubicaciones, tipos, etc.)
CREATE TABLE reference_table (
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL UNIQUE
    -- TODO: Agregar columnas específicas de tu dominio
);

-- Tabla principal de tu dominio
CREATE TABLE main_items (
    id           INTEGER PRIMARY KEY,
    name         TEXT    NOT NULL,
    -- TODO: Agregar columnas específicas
    reference_id INTEGER REFERENCES reference_table (id)
);

-- Tabla hija (transacciones, préstamos, ventas, etc.)
CREATE TABLE child_records (
    id           INTEGER PRIMARY KEY,
    recorded_at  TEXT    NOT NULL DEFAULT (DATE('now')),
    -- TODO: Agregar columnas específicas
    item_id      INTEGER REFERENCES main_items (id)
);

-- ============================================
-- TODO: Insertar datos de prueba realistas
-- Incluir al menos 1 registro "huérfano" en main_items
-- (un item sin ningún child_record asociado)
-- ============================================

-- INSERT INTO reference_table (name) VALUES (...);
-- INSERT INTO main_items (name, reference_id) VALUES (...);
-- INSERT INTO child_records (item_id) VALUES (...);


-- ============================================
-- CONSULTA 1: INNER JOIN principal
-- TODO: Une las dos tablas más importantes
-- Muestra solo los registros con relación en ambas
-- ============================================

-- SELECT
--     mi.name     AS item,
--     cr.recorded_at
-- FROM main_items  mi
-- INNER JOIN child_records cr ON cr.item_id = mi.id;


-- ============================================
-- CONSULTA 2: JOIN con tres tablas
-- TODO: Encadena main_items + child_records + reference_table
-- ============================================

-- SELECT
--     mi.name  AS item,
--     rt.name  AS category,
--     cr.recorded_at
-- FROM main_items mi
-- INNER JOIN reference_table rt ON mi.reference_id = rt.id
-- INNER JOIN child_records   cr ON cr.item_id      = mi.id;


-- ============================================
-- CONSULTA 3: LEFT JOIN — todos los registros
-- TODO: Obtén todos los items aunque no tengan child_records
-- ============================================

-- SELECT
--     mi.name        AS item,
--     cr.recorded_at AS activity
-- FROM main_items  mi
-- LEFT JOIN child_records cr ON cr.item_id = mi.id;


-- ============================================
-- CONSULTA 4: Detectar huérfanos (registros sin actividad)
-- TODO: Agrega WHERE para mostrar solo ítems sin child_records
-- ============================================

-- SELECT
--     mi.name AS item_sin_actividad
-- FROM main_items  mi
-- LEFT JOIN child_records cr ON cr.item_id = mi.id
-- WHERE cr.id IS NULL;


-- ============================================
-- CONSULTA 5: Reporte agregado con LEFT JOIN + COUNT
-- TODO: Cantidad de child_records por item (incluye 0)
-- ============================================

-- SELECT
--     mi.name       AS item,
--     COUNT(cr.id)  AS total_records
-- FROM main_items  mi
-- LEFT JOIN child_records cr ON cr.item_id = mi.id
-- GROUP BY mi.name
-- ORDER BY total_records DESC;





SELECT
    (SELECT COUNT(*) FROM propiedades)  AS total_propiedades,
    (SELECT COUNT(*) FROM agentes)      AS total_agentes,
    (SELECT COUNT(*) FROM clientes)     AS total_clientes,
    (SELECT COUNT(*) FROM contratos)    AS total_contratos,
    (SELECT COUNT(*) FROM agencias)     AS total_agencias;



    SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'propiedades';


SELECT MAX(id_propiedad) FROM propiedades;


SELECT column_default
FROM information_schema.columns
WHERE table_name = 'propiedades' AND column_name = 'id_propiedad';



INSERT INTO propiedades (id_tipo, direccion, precio, area_m2, habitaciones, estado) VALUES
(1, 'Calle 10 # 5-20', 320000000, 110.0, 3, 'Disponible'),
(2, 'Cra 45 # 12-30 Apto 501', 195000000, 62.0, 2, 'Disponible'),
(3, 'Av. Principal Local 12', 210000000, 45.0, NULL, 'Disponible'),
(1, 'Calle 33 # 8-15', 410000000, 135.0, 4, 'Vendido'),
(2, 'Cra 20 # 45-10 Apto 302', 178000000, 58.0, 2, 'Rentado'),
(4, 'Vereda El Rosal Lote 3', 95000000, 500.0, NULL, 'Disponible'),
(1, 'Calle 50 # 20-45', 380000000, 128.0, 3, 'Disponible'),
(3, 'Cra 15 # 30-22 Local B', 165000000, 40.0, NULL, 'Vendido'),
(2, 'Av. Central Apto 804', 225000000, 70.0, 3, 'Disponible'),
(5, 'Parcela La Esperanza', 150000000, 1000.0, NULL, 'Disponible'),
(1, 'Calle 8 # 12-40', 295000000, 100.0, 3, NULL),
(2, 'Cra 60 # 25-18 Apto 202', 205000000, 65.0, 2, 'Disponible'),
(6, 'Bodega Industrial Zona Norte', 480000000, 800.0, NULL, 'Disponible'),
(1, 'Calle 70 # 15-33', 355000000, 115.0, 3, 'Rentado'),
(3, 'Cra 30 # 40-12 Local 5', 190000000, 50.0, NULL, 'Disponible'),
(2, 'Av. Norte Apto 1001', 260000000, 78.0, 3, 'Vendido'),
(7, 'Oficina Torre Central 402', 230000000, 55.0, NULL, 'Disponible'),
(1, 'Calle 22 # 9-11', 340000000, 118.0, 3, 'Disponible'),
(4, 'Lote Campestre Km 5', 110000000, 600.0, NULL, NULL),
(2, 'Cra 12 # 33-40 Apto 605', 215000000, 68.0, 2, 'Disponible'),
(1, 'Calle 5 # 18-25', 298000000, 105.0, 3, 'Disponible'),
(3, 'Av. Sur Local 8', 175000000, 42.0, NULL, 'Rentado'),
(8, 'Finca La Primavera', 620000000, 5000.0, 5, 'Disponible'),
(2, 'Cra 50 # 20-14 Apto 901', 240000000, 72.0, 3, 'Vendido'),
(1, 'Calle 40 # 25-30', 365000000, 122.0, 4, 'Disponible'),
(6, 'Bodega Comercial Sur', 510000000, 850.0, NULL, 'Disponible'),
(2, 'Av. Occidente Apto 303', 188000000, 60.0, 2, 'Disponible'),
(3, 'Cra 18 # 42-19 Local 3', 160000000, 38.0, NULL, NULL),
(1, 'Calle 60 # 10-45', 410000000, 140.0, 4, 'Disponible'),
(7, 'Oficina Business Center 210', 245000000, 58.0, NULL, 'Disponible'),
(2, 'Cra 33 # 15-27 Apto 1102', 255000000, 80.0, 3, 'Rentado'),
(4, 'Lote Esquinero Vía Principal', 130000000, 700.0, NULL, 'Disponible'),
(1, 'Calle 15 # 22-18', 330000000, 112.0, 3, 'Vendido'),
(3, 'Av. Libertad Local 20', 200000000, 48.0, NULL, 'Disponible'),
(2, 'Cra 40 # 8-33 Apto 404', 198000000, 63.0, 2, 'Disponible'),
(8, 'Finca El Retiro', 580000000, 4500.0, 4, 'Disponible'),
(1, 'Calle 28 # 14-20', 375000000, 125.0, 3, NULL),
(6, 'Bodega Norte Industrial 2', 495000000, 780.0, NULL, 'Disponible'),
(2, 'Cra 22 # 35-16 Apto 703', 212000000, 66.0, 2, 'Disponible'),
(3, 'Av. Bolívar Local 15', 172000000, 44.0, NULL, 'Rentado');



SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'contratos';




-- ============================================
-- PROYECTO SEMANAL: JOINs — Semana 09
-- Dominio: Inmobiliaria
-- Tabla principal: propiedades | Secundarias: contratos, agentes
-- ============================================

-- ============================================
-- CONSULTA 1: INNER JOIN principal
-- Propiedades que SÍ tienen contrato asociado (venta/renta concretada)
-- ============================================
SELECT
    p.direccion,
    p.precio,
    c.tipo_contrato,
    c.fecha_firma,
    c.monto_final
FROM propiedades p
INNER JOIN contratos c ON p.id_propiedad = c.id_propiedad;


-- ============================================
-- CONSULTA 2: JOIN con tres tablas
-- Propiedades con contrato, mostrando también el agente que gestionó la venta/renta
-- ============================================
SELECT
    p.direccion,
    p.precio,
    c.tipo_contrato,
    a.nombre    AS nombre_agente,
    a.apellido  AS apellido_agente
FROM propiedades p
INNER JOIN contratos c ON p.id_propiedad = c.id_propiedad
INNER JOIN agentes   a ON c.id_agente    = a.id_agente;


-- ============================================
-- CONSULTA 3: LEFT JOIN — todas las propiedades
-- Incluye propiedades SIN contrato (aún no vendidas ni rentadas)
-- ============================================
SELECT
    p.direccion,
    p.estado,
    c.tipo_contrato,
    c.fecha_firma
FROM propiedades p
LEFT JOIN contratos c ON p.id_propiedad = c.id_propiedad;


-- ============================================
-- CONSULTA 4: Detectar huérfanos
-- Propiedades sin ningún contrato registrado (inventario sin movimiento)
-- ============================================
SELECT
    p.id_propiedad,
    p.direccion,
    p.precio,
    p.estado
FROM propiedades p
LEFT JOIN contratos c ON p.id_propiedad = c.id_propiedad
WHERE c.id_contrato IS NULL;


-- ============================================
-- CONSULTA 5: Reporte agregado con JOINs
-- Cantidad de contratos por propiedad (0 para las que no tienen ninguno)
-- ============================================
SELECT
    p.direccion,
    COUNT(c.id_contrato) AS total_contratos
FROM propiedades p
LEFT JOIN contratos c ON p.id_propiedad = c.id_propiedad
GROUP BY p.direccion
ORDER BY total_contratos DESC;