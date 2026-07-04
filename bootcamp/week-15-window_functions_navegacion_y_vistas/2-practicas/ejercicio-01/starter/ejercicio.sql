-- Semana 15: Window Functions Navegación — Ejercicio 01
-- Ejecuta primero: setup.sql
-- PostgreSQL 16
-- ============================================


-- ============================================
-- PASO 1: LAG — acceder al mes anterior
-- ============================================
-- LAG(amount, 1, 0) mira UNA fila hacia atrás (offset = 1) dentro
-- del orden definido por sale_month. El tercer argumento (0) es
-- el valor por defecto quesólo se usa cuando NO hay fila anterior
-- (es decir, en el primer registro, donde no existe un "mes previo").

SELECT
    sale_month,
    amount,
    LAG(amount, 1, 0) OVER (ORDER BY sale_month) AS prev_amount
FROM monthly_sales
ORDER BY sale_month;


-- ============================================
-- PASO 2: Calcular la diferencia (delta)
-- ============================================
-- Reutilizamos LAG() para restar: monto actual - monto del mes
-- anterior. Si delta es positivo, las ventas crecieron respecto
-- al mes anterior; si es negativo, cayeron.

SELECT
    sale_month,
    amount,
    LAG(amount, 1, 0) OVER (ORDER BY sale_month)          AS prev_amount,
    amount - LAG(amount, 1, 0) OVER (ORDER BY sale_month) AS delta
FROM monthly_sales
ORDER BY sale_month;


-- ============================================
-- PASO 3: LAG por departamento (PARTITION BY)
-- ============================================
-- Sin PARTITION BY, LAG() comparaba meses SIN importar el
-- departamento (mezclaría Engineering con Marketing). Al agregar
-- PARTITION BY department_id, la comparación se reinicia para
-- cada departamento: enero de Marketing ya no mira hacia enero
-- de Engineering, sino que empieza sin "mes anterior" (usa el 0).

SELECT
    sale_month,
    department_id,
    amount,
    LAG(amount, 1, 0) OVER (
        PARTITION BY department_id
        ORDER BY sale_month
    ) AS prev_dept_amount
FROM monthly_sales
ORDER BY department_id, sale_month;


-- ============================================
-- PASO 4: LEAD — ver el siguiente mes
-- ============================================
-- LEAD() es el espejo de LAG(): en vez de mirar hacia atrás,
-- mira HACIA ADELANTE. Aquí el valor por defecto es NULL (en vez
-- de 0), así que el último mes —que no tiene "mes siguiente"—
-- muestra NULL en vez de un número inventado.

SELECT
    sale_month,
    amount,
    LEAD(amount, 1, NULL) OVER (ORDER BY sale_month) AS next_amount
FROM monthly_sales
ORDER BY sale_month;