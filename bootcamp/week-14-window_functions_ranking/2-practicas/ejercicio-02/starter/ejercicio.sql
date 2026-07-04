-- Semana 14: Window Functions — Ejercicio 02
-- Ejecuta primero: setup.sql
-- PostgreSQL 16
-- ============================================


-- ============================================
-- PASO 1: DENSE_RANK() por departamento
-- ============================================
-- Clasifica a los empleados por salario, DENTRO de su propio
-- departamento (PARTITION BY reinicia el conteo en cada grupo).
-- Si dos personas empatan en salario, comparten el mismo rango
-- y NO se salta el siguiente número (a diferencia de RANK()).

SELECT
    first_name,
    department_id,
    salary,
    DENSE_RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS dept_rank
FROM employees
ORDER BY department_id, salary DESC;


-- ============================================
-- PASO 2: El más alto por departamento (top-1)
-- ============================================
-- No se puede filtrar una window function directamente en el
-- mismo SELECT donde se calcula (ej. WHERE dept_rank = 1 fallaría
-- aquí). Por eso usamos un CTE: primero calculamos el ranking
-- dentro de "ranked", y luego filtramos afuera con WHERE.

WITH ranked AS (
    SELECT
        first_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS dept_rank
    FROM employees
)
SELECT first_name, department_id, salary
FROM ranked
WHERE dept_rank = 1;


-- ============================================
-- PASO 3: Top-2 por departamento
-- ============================================
-- Mismo patrón que el Paso 2, pero cambiamos el filtro a
-- dept_rank <= 2 para traer los DOS mejores salarios de cada
-- departamento. Si hay un empate en el puesto 2, van a aparecer
-- AMBOS empleados (porque DENSE_RANK no distingue empates).

WITH ranked AS (
    SELECT
        first_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS dept_rank
    FROM employees
)
SELECT first_name, department_id, salary, dept_rank
FROM ranked
WHERE dept_rank <= 2
ORDER BY department_id, dept_rank;


-- ============================================
-- PASO 4: Top-3 global de la empresa
-- ============================================
-- Aquí quitamos el PARTITION BY, así que el ranking ya NO es
-- por departamento sino de TODA la empresa junta. Filtramos
-- con company_rank <= 3 para quedarnos solo con los 3 salarios
-- más altos de toda la compañía.

WITH global_ranked AS (
    SELECT
        first_name,
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS company_rank
    FROM employees
)
SELECT first_name, salary, company_rank
FROM global_ranked
WHERE company_rank <= 3
ORDER BY company_rank;