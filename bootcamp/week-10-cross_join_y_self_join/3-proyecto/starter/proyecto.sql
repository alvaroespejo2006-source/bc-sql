-- ============================================
-- PROYECTO SEMANAL: SELF JOIN en tu dominio
-- Semana 10 — CROSS JOIN y SELF JOIN
-- Dominio: Inmobiliaria
-- Jerarquía: Ciudad → Zona → Barrio
-- ============================================

DROP TABLE IF EXISTS zonas_geograficas;

CREATE TABLE zonas_geograficas (
    id             SERIAL  PRIMARY KEY,
    name           TEXT    NOT NULL UNIQUE,
    tipo           TEXT    NOT NULL CHECK (tipo IN ('ciudad', 'zona', 'barrio')),
    parent_zona_id INTEGER REFERENCES zonas_geograficas (id)  -- auto-referencial
);

-- ============================================
-- NIVEL 0: Ciudad (raíz, parent_zona_id = NULL) → id = 1
-- ============================================
INSERT INTO zonas_geograficas (name, tipo, parent_zona_id)
VALUES ('Bogotá', 'ciudad', NULL);

-- ============================================
-- NIVEL 1: Zonas, reportan a Bogotá (id = 1) → ids 2 a 8
-- ============================================
INSERT INTO zonas_geograficas (name, tipo, parent_zona_id) VALUES
    ('Zona Norte',     'zona', 1),
    ('Zona Sur',       'zona', 1),
    ('Zona Occidente', 'zona', 1),
    ('Zona Centro',    'zona', 1),
    ('Chapinero',      'zona', 1),
    ('Usaquén',        'zona', 1),
    ('Suba',           'zona', 1);

-- ============================================
-- NIVEL 2: Barrios, 10 por cada zona (7 zonas × 10 = 70)
-- generate_series crea automáticamente las combinaciones
-- ============================================
INSERT INTO zonas_geograficas (name, tipo, parent_zona_id)
SELECT
    'Barrio ' || s || ' - ' || z.name,
    'barrio',
    z.id
FROM generate_series(1, 10) AS s
CROSS JOIN (SELECT id, name FROM zonas_geograficas WHERE tipo = 'zona') AS z;

-- 2 barrios adicionales para completar el mínimo de 80 filas
INSERT INTO zonas_geograficas (name, tipo, parent_zona_id) VALUES
    ('Barrio 11 - Zona Norte', 'barrio', 2),
    ('Barrio 11 - Zona Sur',   'barrio', 3);

-- Verificación: debe dar 80
-- SELECT COUNT(*) FROM zonas_geograficas;


-- ============================================
-- CONSULTA 1: SELF JOIN básico (INNER JOIN)
-- Barrio y su zona. Excluye la raíz (ciudad, sin padre)
-- ============================================
SELECT
    hijo.name  AS zona_o_barrio,
    padre.name AS zona_padre
FROM zonas_geograficas hijo
INNER JOIN zonas_geograficas padre ON hijo.parent_zona_id = padre.id;


-- ============================================
-- CONSULTA 2: Incluir la raíz con LEFT JOIN
-- ============================================
SELECT
    hijo.name                       AS zona_o_barrio,
    COALESCE(padre.name, 'Raíz')    AS zona_padre
FROM zonas_geograficas hijo
LEFT JOIN zonas_geograficas padre ON hijo.parent_zona_id = padre.id
ORDER BY zona_padre, zona_o_barrio;


-- ============================================
-- CONSULTA 3: Contar hijos por padre
-- Cuántos barrios/zonas tiene cada zona/ciudad
-- ============================================
SELECT
    padre.name       AS zona_padre,
    COUNT(hijo.id)    AS total_hijos
FROM zonas_geograficas padre
LEFT JOIN zonas_geograficas hijo ON hijo.parent_zona_id = padre.id
GROUP BY padre.id, padre.name
HAVING COUNT(hijo.id) > 0
ORDER BY total_hijos DESC;


-- ============================================
-- CONSULTA 4: Dos niveles jerárquicos
-- Barrio → Zona → Ciudad
-- ============================================
SELECT
    hijo.name   AS barrio,
    padre.name  AS zona,
    abuelo.name AS ciudad
FROM zonas_geograficas hijo
LEFT JOIN zonas_geograficas padre  ON hijo.parent_zona_id  = padre.id
LEFT JOIN zonas_geograficas abuelo ON padre.parent_zona_id = abuelo.id
ORDER BY ciudad, zona, barrio;






-- ============================================
-- PROYECTO SEMANAL: SELF JOIN en tu dominio
-- Semana 10 — CROSS JOIN y SELF JOIN
-- Dominio: Inmobiliaria — Jerarquía de zonas geográficas
-- ============================================

DROP TABLE IF EXISTS zonas_geograficas;

CREATE TABLE zonas_geograficas (
    id        SERIAL  PRIMARY KEY,
    nombre    TEXT    NOT NULL,
    tipo      TEXT    NOT NULL CHECK (tipo IN ('ciudad', 'zona', 'barrio')),
    parent_id INTEGER REFERENCES zonas_geograficas (id)  -- auto-referencial
);

-- ============================================
-- DATOS DE PRUEBA — 3 niveles de jerarquía
-- Nivel 0: 1 ciudad (raíz, parent_id = NULL)      → id = 1
-- Nivel 1: 10 zonas (hijas de la ciudad)          → ids 2-11
-- Nivel 2: 70 barrios (hijos de las zonas)        → ids 12-81
-- Total: 81 filas
-- ============================================

-- Nivel 0: la ciudad (raíz)
INSERT INTO zonas_geograficas (nombre, tipo, parent_id) VALUES
    ('Bogotá', 'ciudad', NULL);

-- Nivel 1: 10 zonas, todas hijas de Bogotá (id=1)
INSERT INTO zonas_geograficas (nombre, tipo, parent_id) VALUES
    ('Zona Norte',       'zona', 1),
    ('Zona Sur',         'zona', 1),
    ('Zona Centro',      'zona', 1),
    ('Zona Occidente',   'zona', 1),
    ('Zona Oriente',     'zona', 1),
    ('Zona Chapinero',   'zona', 1),
    ('Zona Usaquén',     'zona', 1),
    ('Zona Suba',        'zona', 1),
    ('Zona Kennedy',     'zona', 1),
    ('Zona Engativá',    'zona', 1);

-- Nivel 2: 70 barrios, distribuidos entre las 10 zonas (ids 2 a 11)
INSERT INTO zonas_geograficas (nombre, tipo, parent_id)
SELECT
    'Barrio ' || gs AS nombre,
    'barrio'        AS tipo,
    2 + (gs % 10)   AS parent_id  -- reparte cíclicamente entre las zonas 2-11
FROM generate_series(1, 70) AS gs;


-- ============================================
-- CONSULTA 1: SELF JOIN básico (INNER JOIN)
-- Muestra cada zona/barrio junto a su padre. Excluye la raíz (Bogotá).
-- ============================================
SELECT
    child.nombre  AS zona,
    parent.nombre AS zona_padre
FROM zonas_geograficas child
INNER JOIN zonas_geograficas parent ON child.parent_id = parent.id;


-- ============================================
-- CONSULTA 2: Incluir la raíz (LEFT JOIN + COALESCE)
-- Igual que la anterior, pero incluye Bogotá etiquetada como raíz.
-- ============================================
SELECT
    child.nombre                          AS zona,
    COALESCE(parent.nombre, 'Ciudad raíz') AS zona_padre
FROM zonas_geograficas child
LEFT JOIN zonas_geograficas parent ON child.parent_id = parent.id
ORDER BY zona_padre, zona;


-- ============================================
-- CONSULTA 3: Contar hijos por padre
-- Cuántas zonas/barrios dependen directamente de cada zona superior.
-- ============================================
SELECT
    parent.nombre     AS zona_padre,
    COUNT(child.id)   AS total_hijos
FROM zonas_geograficas parent
LEFT JOIN zonas_geograficas child ON child.parent_id = parent.id
GROUP BY parent.id, parent.nombre
HAVING COUNT(child.id) > 0
ORDER BY total_hijos DESC;


-- ============================================
-- CONSULTA 4: Dos niveles jerárquicos
-- Barrio → su zona → la ciudad (abuelo)
-- ============================================
SELECT
    child.nombre       AS barrio,
    parent.nombre      AS zona,
    grandparent.nombre AS ciudad
FROM zonas_geograficas child
LEFT JOIN zonas_geograficas parent      ON child.parent_id  = parent.id
LEFT JOIN zonas_geograficas grandparent ON parent.parent_id = grandparent.id
ORDER BY ciudad, zona, barrio;