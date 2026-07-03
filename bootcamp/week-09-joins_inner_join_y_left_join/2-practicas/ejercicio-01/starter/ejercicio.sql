-- ============================================
-- Semana 09: INNER JOIN — Ejercicio 01
-- ============================================
-- Ejecuta primero: setup.sql

-- ============================================
-- PASO 1: INNER JOIN básico
-- ============================================

SELECT
    e.first_name,
    e.last_name,
    d.name AS department
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;


-- ============================================
-- PASO 2: Agregar columnas de ambas tablas
-- ============================================

SELECT
    e.first_name,
    e.salary,
    d.name        AS department,
    d.budget
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
ORDER BY e.salary DESC;


-- ============================================
-- PASO 3: JOIN con filtro WHERE
-- ============================================

SELECT
    e.first_name,
    e.last_name,
    e.level
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
WHERE d.name      = 'Engineering'
  AND e.is_active = 1;


-- ============================================
-- PASO 4: JOIN de tres tablas
-- ============================================

SELECT
    e.first_name,
    d.name    AS department,
    l.name    AS location,
    l.country
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
INNER JOIN locations   l ON d.location_id   = l.id
ORDER BY l.country, d.name;