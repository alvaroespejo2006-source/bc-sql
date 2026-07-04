-- Semana 16: Índices y Funciones — Ejercicio 01
-- Ejecuta primero: setup.sql
-- PostgreSQL 16
-- ============================================


-- ============================================
-- PASO 1: EXPLAIN sin índice
-- ============================================
-- EXPLAIN te muestra el "plan" que PostgreSQL usará para ejecutar
-- la consulta, SIN ejecutarla de verdad. Sin ningún índice en
-- department_id, la única forma de encontrar las filas es leer
-- la tabla completa de principio a fin — esto se llama
-- "Seq Scan" (sequential scan).

EXPLAIN
SELECT * FROM employees WHERE department_id = 2;


-- ============================================
-- PASO 2: Crear índice y repetir EXPLAIN
-- ============================================
-- CREATE INDEX construye una estructura B-tree ordenada sobre la
-- columna department_id, para que PostgreSQL pueda "saltar"
-- directo a las filas que buscamos sin leer toda la tabla.

CREATE INDEX idx_employees_department_id
    ON employees (department_id);

EXPLAIN
SELECT * FROM employees WHERE department_id = 2;


-- ============================================
-- PASO 3: Índice UNIQUE en email
-- ============================================
-- UNIQUE INDEX hace dos cosas a la vez: garantiza que no existan
-- dos empleados con el mismo email (como una restricción), Y
-- acelera las búsquedas exactas por ese campo.
-- EXPLAIN ANALYZE, a diferencia de EXPLAIN normal, SÍ ejecuta la
-- consulta de verdad y muestra tiempos reales de ejecución.

CREATE UNIQUE INDEX idx_employees_email
    ON employees (email);

EXPLAIN ANALYZE
SELECT * FROM employees WHERE email = 'ana.garcia@empresa.com';


-- ============================================
-- PASO 4: Ver los índices creados
-- ============================================
-- pg_indexes es una vista del catálogo del sistema de PostgreSQL
-- que lista todos los índices existentes. Aquí filtramos solo
-- los de la tabla employees, para confirmar que los dos índices
-- que creamos (department_id y email) sí quedaron registrados.

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'employees';

EXPLAIN
SELECT * FROM employees WHERE department_id = 2;
