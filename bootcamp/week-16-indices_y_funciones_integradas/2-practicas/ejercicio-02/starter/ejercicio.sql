-- Semana 16: Índices y Funciones — Ejercicio 02
-- Ejecuta primero: setup.sql
-- PostgreSQL 16
-- ============================================


-- ============================================
-- PASO 1: Funciones de cadena
-- ============================================
-- UPPER() convierte el texto a mayúsculas; el operador || concatena
-- cadenas (aquí unimos nombre + espacio + apellido).
-- POSITION('@' IN email) encuentra en qué posición está el
-- carácter '@' dentro del email; sumándole 1 obtenemos dónde
-- empieza el dominio, y SUBSTRING(email FROM ...) extrae desde
-- ahí hasta el final. LENGTH() cuenta caracteres.

SELECT
    UPPER(first_name) || ' ' || UPPER(last_name) AS full_name_upper,
    SUBSTRING(email FROM POSITION('@' IN email) + 1) AS email_domain,
    LENGTH(first_name) AS name_length
FROM employees
ORDER BY full_name_upper;


-- ============================================
-- PASO 2: Funciones de fecha
-- ============================================
-- AGE(fecha1, fecha2) calcula la diferencia entre dos fechas y
-- devuelve un "intervalo" (años, meses, días). EXTRACT(YEAR FROM ...)
-- saca solo la parte de años de ese intervalo, y el ::INT lo
-- convierte a un número entero limpio. TO_CHAR formatea la fecha
-- como texto legible, usando un patrón (DD/MM/YYYY = día/mes/año).

SELECT
    first_name,
    hire_date,
    TO_CHAR(hire_date, 'DD/MM/YYYY') AS hire_fmt,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::INT AS years_in_company
FROM employees
ORDER BY hire_date;


-- ============================================
-- PASO 3: Funciones numéricas
-- ============================================
-- ROUND(numero, decimales) redondea al número de decimales
-- indicado. Aquí lo usamos para: dividir el salario anual entre
-- 12 (salario mensual), multiplicarlo por 1.10 (agregar 10% de
-- bono), y calcular cuánto es ese bono en dinero (la diferencia
-- entre el salario con bono y el salario original).

SELECT
    first_name,
    salary,
    ROUND(salary / 12, 2)            AS monthly_salary,
    ROUND(salary * 1.10, 2)          AS salary_with_bonus,
    ROUND(salary * 1.10 - salary, 2) AS bonus_amount
FROM employees
ORDER BY salary DESC;


-- ============================================
-- PASO 4: Reporte combinado
-- ============================================
-- Aquí juntamos las tres categorías de funciones en un solo
-- reporte: cadena (UPPER + concatenación), fecha (TO_CHAR +
-- EXTRACT/AGE) y numérica (ROUND). Filtramos solo empleados
-- activos (WHERE is_active = TRUE) y ordenamos primero por
-- antigüedad (years DESC) y luego por salario (salary DESC).

SELECT
    UPPER(first_name) || ' ' || UPPER(last_name)         AS employee,
    TO_CHAR(hire_date, 'Mon YYYY')                       AS hired,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::INT AS years,
    ROUND(salary / 12, 2)                                AS monthly
FROM employees
WHERE is_active = TRUE
ORDER BY years DESC, salary DESC;