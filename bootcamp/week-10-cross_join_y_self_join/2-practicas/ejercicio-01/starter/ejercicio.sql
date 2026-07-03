-- ============================================
-- Semana 10: CROSS JOIN — Ejercicio 01
-- ============================================
-- Ejecuta primero: setup.sql

-- ============================================
-- PASO 1: CROSS JOIN básico
-- ============================================

SELECT
    d.name   AS department,
    l.name   AS level
FROM departments d
CROSS JOIN job_levels l
ORDER BY d.name, l.rank;


-- ============================================
-- PASO 2: Verificar el total de filas
-- ============================================

SELECT COUNT(*) AS total_combinations
FROM departments d
CROSS JOIN job_levels l;


-- ============================================
-- PASO 3: Filtrar combinaciones con WHERE
-- ============================================

SELECT
    d.name  AS department,
    l.name  AS level
FROM departments  d
CROSS JOIN job_levels l
WHERE d.name = 'Engineering'
ORDER BY l.rank;


-- ============================================
-- PASO 4: CROSS JOIN con columna calculada
-- ============================================

SELECT
    d.name          AS department,
    l.name          AS level,
    l.base_salary   AS base_salary
FROM departments  d
CROSS JOIN job_levels l
ORDER BY d.name, l.rank;