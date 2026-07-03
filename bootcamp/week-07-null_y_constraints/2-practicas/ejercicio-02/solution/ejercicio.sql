-- ============================================
-- Semana 07: Constraints y PRAGMA — Ejercicio 02
-- ============================================
-- Ejecuta primero: setup.sql
-- NOTA: PRAGMA es sintaxis de SQLite. Como usamos PostgreSQL,
-- se reemplaza por consultas equivalentes a information_schema.

-- ============================================
-- PASO 1: Verificar constraints (equivalente a PRAGMA table_info)
-- ============================================

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'employees';


-- ============================================
-- PASO 2: Insertar datos válidos
-- ============================================

INSERT INTO employees
    (id, first_name, last_name, salary, department_id)
VALUES
    (11, 'Hugo', 'Reyes', 62000.00, 2);

-- ============================================
-- PASO 3: NULLIF para división segura
-- ============================================

SELECT
    first_name,
    salary,
    COALESCE(bonus, 0)                           AS bonus,
    COALESCE(bonus, 0) / NULLIF(salary, 0) * 100 AS bonus_pct
FROM employees;


-- ============================================
-- PASO 4: Verificar integridad referencial
-- ============================================

SELECT DISTINCT department_id
FROM   employees
WHERE  department_id NOT IN (SELECT id FROM departments);





