-- Semana 15: Window Functions Navegación — Ejercicio 02
-- Ejecuta primero: setup.sql
-- PostgreSQL 16
-- ============================================


-- ============================================
-- PASO 1: FIRST_VALUE por departamento
-- ============================================
-- FIRST_VALUE() ordena internamente por "amount DESC" dentro de
-- cada departamento (PARTITION BY), y devuelve el valor de la
-- PRIMERA fila de ese orden — es decir, el monto más alto — mismo
-- en TODAS las filas de ese departamento (no colapsa filas).

SELECT
    sale_month,
    department_id,
    amount,
    FIRST_VALUE(amount) OVER (
        PARTITION BY department_id
        ORDER BY amount DESC
    ) AS dept_best
FROM monthly_sales
ORDER BY department_id, sale_month;


-- ============================================
-- PASO 2: LAST_VALUE con frame extendido
-- ============================================
-- OJO: por defecto, una window function solo "ve" desde el inicio
-- de la partición hasta la FILA ACTUAL (esto se llama el "frame").
-- Por eso LAST_VALUE() sin especificar el frame te devolvería el
-- valor de la fila actual, no el último real de la partición.
-- Con ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING le
-- decimos: "considera TODAS las filas de la partición, de inicio
-- a fin", así LAST_VALUE trae el monto más bajo (el último en el
-- orden DESC).

SELECT
    sale_month,
    department_id,
    amount,
    LAST_VALUE(amount) OVER (
        PARTITION BY department_id
        ORDER BY amount DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_worst
FROM monthly_sales
ORDER BY department_id, sale_month;


-- ============================================
-- PASO 3: Alias de ventana con WINDOW
-- ============================================
-- Repetir la misma definición de ventana (PARTITION BY + ORDER BY
-- + frame) dos veces es propenso a errores. La cláusula WINDOW
-- permite nombrarla una sola vez como "w" y reutilizarla en
-- ambas funciones — el resultado es idéntico al de los pasos
-- anteriores, pero el código es más limpio y fácil de mantener.

SELECT
    sale_month,
    department_id,
    amount,
    FIRST_VALUE(amount) OVER w AS dept_best,
    LAST_VALUE(amount)  OVER w AS dept_worst
FROM monthly_sales
WINDOW w AS (
    PARTITION BY department_id
    ORDER BY amount DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
ORDER BY department_id, sale_month;


-- ============================================
-- PASO 4: CREATE VIEW y consulta a la vista
-- ============================================
-- Guardamos la consulta del Paso 3 como una VISTA con nombre
-- (v_dept_sales_analysis). A partir de ahora, en vez de reescribir
-- toda esta lógica de window functions cada vez, podemos tratarla
-- como si fuera una tabla normal: hacerle SELECT, WHERE, JOIN, etc.
-- La vista no guarda datos — cada vez que la consultas, PostgreSQL
-- vuelve a ejecutar la consulta original por debajo.

CREATE OR REPLACE VIEW v_dept_sales_analysis AS
SELECT
    sale_month,
    department_id,
    amount,
    FIRST_VALUE(amount) OVER w AS dept_best,
    LAST_VALUE(amount)  OVER w AS dept_worst
FROM monthly_sales
WINDOW w AS (
    PARTITION BY department_id
    ORDER BY amount DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);

-- Consultamos la vista como si fuera una tabla, filtrando solo
-- el departamento 1 (Engineering) con un WHERE normal.
SELECT *
FROM v_dept_sales_analysis
WHERE department_id = 1
ORDER BY sale_month;