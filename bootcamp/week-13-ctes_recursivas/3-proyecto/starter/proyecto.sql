-- ============================================
-- PROYECTO SEMANAL: Jerarquías con CTEs Recursivas
-- Semana 13 — WITH RECURSIVE
-- PostgreSQL 16 — Dominio: Inmobiliaria (zonas geográficas)
-- ============================================

DROP TABLE IF EXISTS zonas_geograficas CASCADE;

CREATE TABLE zonas_geograficas (
    id        SERIAL  PRIMARY KEY,
    name      TEXT    NOT NULL,
    tipo      TEXT    NOT NULL CHECK (tipo IN ('ciudad', 'zona', 'barrio')),
    parent_id INT     REFERENCES zonas_geograficas (id)
);

-- ============================================
-- DATOS: 3 niveles, 200 filas totales
-- Nivel 1: 1 ciudad (raíz)               -> id = 1
-- Nivel 2: 19 zonas (hijas de la ciudad) -> ids 2-20
-- Nivel 3: 180 barrios (hijos de zonas)  -> ids 21-200
-- ============================================

-- Nivel 1: la ciudad (raíz)
INSERT INTO zonas_geograficas (name, tipo, parent_id) VALUES
    ('Bogotá', 'ciudad', NULL);

-- Nivel 2: 19 zonas, todas hijas de Bogotá (id = 1)
INSERT INTO zonas_geograficas (name, tipo, parent_id)
SELECT 'Zona ' || gs, 'zona', 1
FROM generate_series(1, 19) AS gs;

-- Nivel 3: 180 barrios, repartidos cíclicamente entre las 19 zonas (ids 2-20)
INSERT INTO zonas_geograficas (name, tipo, parent_id)
SELECT
    'Barrio ' || gs,
    'barrio',
    2 + (gs % 19)
FROM generate_series(1, 180) AS gs;

-- Verificación: debe dar 200
-- SELECT COUNT(*) FROM zonas_geograficas;


-- ============================================
-- CONSULTA 1: Árbol completo con depth y path
-- Recorre todos los nodos desde la ciudad raíz
-- ============================================
WITH RECURSIVE arbol AS (
    -- Caso base: la ciudad raíz (sin parent_id)
    SELECT
        id,
        name,
        parent_id,
        1        AS depth,
        name     AS path
    FROM zonas_geograficas
    WHERE parent_id IS NULL

    UNION ALL

    -- Caso recursivo: cada nodo hijo se une a su padre ya procesado
    SELECT
        z.id,
        z.name,
        z.parent_id,
        a.depth + 1,
        a.path || ' > ' || z.name
    FROM zonas_geograficas z
    INNER JOIN arbol a ON z.parent_id = a.id
)
SELECT
    depth,
    REPEAT('  ', depth - 1) || name AS indented_name,
    path
FROM arbol
ORDER BY path;


-- ============================================
-- CONSULTA 2: Nodos de un nivel específico
-- Muestra solo el nivel 2 (las 19 zonas)
-- ============================================
WITH RECURSIVE arbol AS (
    SELECT id, name, parent_id, 1 AS depth, name AS path
    FROM zonas_geograficas
    WHERE parent_id IS NULL
    UNION ALL
    SELECT z.id, z.name, z.parent_id, a.depth + 1, a.path || ' > ' || z.name
    FROM zonas_geograficas z
    INNER JOIN arbol a ON z.parent_id = a.id
)
SELECT name, depth, path
FROM arbol
WHERE depth = 2
ORDER BY path;


-- ============================================
-- CONSULTA 3: Hojas del árbol (nodos sin hijos)
-- Los barrios son las hojas: ningún otro nodo los tiene como parent_id
-- ============================================
SELECT
    n.id,
    n.name
FROM zonas_geograficas n
WHERE NOT EXISTS (
    SELECT 1
    FROM zonas_geograficas child
    WHERE child.parent_id = n.id
)
ORDER BY n.name;


SELECT COUNT(*) FROM zonas_geograficas;


INSERT INTO zonas_geograficas (name, tipo, parent_id)
VALUES ('Barrio 181', 'barrio', 2);



WITH RECURSIVE arbol AS (
    SELECT
        id,
        name,
        parent_id,
        1        AS depth,
        name     AS path
    FROM zonas_geograficas
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        z.id,
        z.name,
        z.parent_id,
        a.depth + 1,
        a.path || ' > ' || z.name
    FROM zonas_geograficas z
    INNER JOIN arbol a ON z.parent_id = a.id
)
SELECT
    depth,
    REPEAT('  ', depth - 1) || name AS indented_name,
    path
FROM arbol
ORDER BY path;




WITH RECURSIVE arbol AS (
    SELECT id, name, parent_id, 1 AS depth, name AS path
    FROM zonas_geograficas
    WHERE parent_id IS NULL
    UNION ALL
    SELECT z.id, z.name, z.parent_id, a.depth + 1, a.path || ' > ' || z.name
    FROM zonas_geograficas z
    INNER JOIN arbol a ON z.parent_id = a.id
)
SELECT name, depth, path
FROM arbol
WHERE depth = 2
ORDER BY path;



SELECT
    n.id,
    n.name
FROM zonas_geograficas n
WHERE NOT EXISTS (
    SELECT 1
    FROM zonas_geograficas child
    WHERE child.parent_id = n.id
)
ORDER BY n.name;



SELECT COUNT(*) FROM zonas_geograficas;



SELECT
    n.id,
    n.name
FROM zonas_geograficas n
WHERE NOT EXISTS (
    SELECT 1
    FROM zonas_geograficas child
    WHERE child.parent_id = n.id
)
ORDER BY n.name;




WITH RECURSIVE arbol AS (
    SELECT
        id,
        name,
        parent_id,
        1        AS depth,
        name     AS path
    FROM zonas_geograficas
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        z.id,
        z.name,
        z.parent_id,
        a.depth + 1,
        a.path || ' > ' || z.name
    FROM zonas_geograficas z
    INNER JOIN arbol a ON z.parent_id = a.id
)
SELECT
    depth,
    REPEAT('  ', depth - 1) || name AS indented_name,
    path
FROM arbol
ORDER BY path;




SELECT * FROM zonas_geograficas WHERE parent_id IS NULL;


SELECT id, name, tipo, parent_id
FROM zonas_geograficas
ORDER BY id
LIMIT 10;







DROP TABLE IF EXISTS zonas_geograficas CASCADE;

CREATE TABLE zonas_geograficas (
    id        SERIAL  PRIMARY KEY,
    name      TEXT    NOT NULL,
    tipo      TEXT    NOT NULL CHECK (tipo IN ('ciudad', 'zona', 'barrio')),
    parent_id INT     REFERENCES zonas_geograficas (id)
);

INSERT INTO zonas_geograficas (name, tipo, parent_id) VALUES
    ('Bogotá', 'ciudad', NULL);

INSERT INTO zonas_geograficas (name, tipo, parent_id)
SELECT 'Zona ' || gs, 'zona', 1
FROM generate_series(1, 19) AS gs;

INSERT INTO zonas_geograficas (name, tipo, parent_id)
SELECT
    'Barrio ' || gs,
    'barrio',
    2 + (gs % 19)
FROM generate_series(1, 180) AS gs;

INSERT INTO zonas_geograficas (name, tipo, parent_id)
VALUES ('Barrio 181', 'barrio', 2);



SELECT * FROM zonas_geograficas WHERE parent_id IS NULL;



SELECT COUNT(*) FROM employees;


-- Confirma que hay un CEO sin manager (caso base)
SELECT * FROM employees WHERE manager_id IS NULL;

SELECT COUNT(*) FROM daily_sales;


-- Confirma que el 3 y 6 de enero no tienen ventas
SELECT DISTINCT sale_date FROM daily_sales ORDER BY sale_date;




-- Debe dar 200
SELECT COUNT(*) FROM zonas_geograficas;

-- Debe mostrar exactamente 1 fila: Bogotá
SELECT * FROM zonas_geograficas WHERE parent_id IS NULL;

-- Debe mostrar 19 filas (las zonas)
SELECT COUNT(*) FROM zonas_geograficas WHERE tipo = 'zona';

-- Debe mostrar 181 filas (los barrios)
SELECT COUNT(*) FROM zonas_geograficas WHERE tipo = 'barrio';