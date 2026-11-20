-- =====================================================================
--  APRENDIZ DE BRUJO: SQL con MySQL
--  Script completo del libro (E01 - E15)
--  Autor: Fernando Gutiérrez
--  Motor: MySQL 8.x  |  Codificación: utf8mb4
--
--  Cómo usarlo:
--    mysql -u root -p < aprendiz_brujo_mysql.sql
--    (o abrirlo en MySQL Workbench y ejecutar todo con el rayo)
--
--  El script se puede ejecutar varias veces: al inicio borra y vuelve
--  a crear la base de datos de práctica.
--
--  Las cuatro profesiones del libro:
--    MEDICINA        -> medicos, pacientes, consultas
--    DERECHO         -> abogados, clientes, procesos
--    INGENIERIA      -> proyectos, ensayos
--    ADMINISTRACION  -> empleados, productos, ventas
--
--  Las 15 estructuras básicas:
--    ESENCIALES (9)
--      E01 SELECT            E06 JOIN
--      E02 WHERE             E07 INSERT
--      E03 ORDER BY y LIMIT  E08 UPDATE
--      E04 Agregación        E09 DELETE
--      E05 GROUP BY y HAVING
--    NO ESENCIALES (6)
--      E10 Subconsultas      E13 Índices
--      E11 CASE y funciones  E14 Procedimientos y triggers
--      E12 Vistas            E15 Transacciones
-- =====================================================================


-- =====================================================================
--  E00. PREPARACIÓN: crear la base de datos, las tablas y los datos
-- =====================================================================

DROP DATABASE IF EXISTS aprendiz_brujo;
CREATE DATABASE aprendiz_brujo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE aprendiz_brujo;

-- ---------- MEDICINA ----------
CREATE TABLE medicos (
    id_medico     INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    especialidad  VARCHAR(50) NOT NULL
);

CREATE TABLE pacientes (
    id_paciente      INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(80) NOT NULL,
    fecha_nacimiento DATE        NOT NULL,
    ciudad           VARCHAR(50) NOT NULL,
    eps              VARCHAR(40) NULL            -- NULL = sin EPS
);

CREATE TABLE consultas (
    id_consulta  INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente  INT           NOT NULL,
    id_medico    INT           NOT NULL,
    fecha        DATE          NOT NULL,
    diagnostico  VARCHAR(100)  NOT NULL,
    valor        DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    FOREIGN KEY (id_medico)   REFERENCES medicos(id_medico)
);

-- ---------- DERECHO ----------
CREATE TABLE abogados (
    id_abogado  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(80) NOT NULL,
    area        VARCHAR(50) NOT NULL
);

CREATE TABLE clientes (
    id_cliente  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    ciudad      VARCHAR(50)  NOT NULL
);

CREATE TABLE procesos (
    id_proceso    INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT           NOT NULL,
    id_abogado    INT           NOT NULL,
    tipo          VARCHAR(60)   NOT NULL,
    estado        ENUM('Activo','Terminado','Suspendido') NOT NULL DEFAULT 'Activo',
    fecha_inicio  DATE          NOT NULL,
    honorarios    DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_abogado) REFERENCES abogados(id_abogado)
);

-- ---------- INGENIERÍA ----------
CREATE TABLE proyectos (
    id_proyecto  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(80)   NOT NULL,
    ciudad       VARCHAR(50)   NOT NULL,
    presupuesto  DECIMAL(15,2) NOT NULL,
    estado       VARCHAR(20)   NOT NULL
);

CREATE TABLE ensayos (
    id_ensayo        INT AUTO_INCREMENT PRIMARY KEY,
    id_proyecto      INT          NOT NULL,
    material         VARCHAR(50)  NOT NULL,
    resistencia_mpa  DECIMAL(6,2) NOT NULL,
    fecha            DATE         NOT NULL,
    FOREIGN KEY (id_proyecto) REFERENCES proyectos(id_proyecto)
);

-- ---------- ADMINISTRACIÓN ----------
CREATE TABLE empleados (
    id_empleado    INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80)   NOT NULL,
    cargo          VARCHAR(40)   NOT NULL,
    salario        DECIMAL(12,2) NOT NULL,
    id_jefe        INT           NULL,            -- NULL = no tiene jefe
    fecha_ingreso  DATE          NOT NULL,
    FOREIGN KEY (id_jefe) REFERENCES empleados(id_empleado)
);

CREATE TABLE productos (
    id_producto  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(60)   NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    stock        INT           NOT NULL DEFAULT 0
);

CREATE TABLE ventas (
    id_venta     INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado  INT  NOT NULL,
    id_producto  INT  NOT NULL,
    cantidad     INT  NOT NULL CHECK (cantidad > 0),
    fecha        DATE NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ---------- DATOS DE PRÁCTICA (ficticios) ----------
INSERT INTO medicos (nombre, especialidad) VALUES
    ('Dra. Laura Mejía',    'Medicina Interna'),
    ('Dr. Andrés Ríos',     'Pediatría'),
    ('Dra. Camila Torres',  'Geriatría'),
    ('Dr. Julián Ospina',   'Cardiología');

INSERT INTO pacientes (nombre, fecha_nacimiento, ciudad, eps) VALUES
    ('Marta Quintero',      '1948-03-12', 'Cali',    'Sanitas'),
    ('Luis Fernando Paz',   '1955-07-30', 'Palmira', 'Nueva EPS'),
    ('Rosa Elena Cuero',    '1941-11-02', 'Cali',    'Sura'),
    ('Sofía Vargas',        '2018-05-21', 'Jamundí', 'Sanitas'),
    ('Pedro Pablo Mina',    '1962-09-15', 'Cali',    NULL),
    ('Ana Lucía Rojas',     '1990-01-08', 'Yumbo',   'Sura');

INSERT INTO consultas (id_paciente, id_medico, fecha, diagnostico, valor) VALUES
    (1, 3, '2026-09-02', 'Hipertensión arterial',      85000),
    (1, 4, '2026-09-20', 'Control cardiológico',      120000),
    (2, 1, '2026-09-05', 'Diabetes mellitus tipo 2',   90000),
    (3, 3, '2026-10-01', 'Osteoartritis',              85000),
    (4, 2, '2026-10-10', 'Control de crecimiento',     70000),
    (3, 1, '2026-10-15', 'Hipertensión arterial',      90000),
    (6, 1, '2026-11-03', 'Gastritis',                  90000),
    (2, 3, '2026-11-10', 'Control geriátrico',         85000);

INSERT INTO abogados (nombre, area) VALUES
    ('Dr. Mauricio Salazar', 'Laboral'),
    ('Dra. Paola Herrera',   'Constitucional'),
    ('Dr. Esteban Cruz',     'Disciplinario');

INSERT INTO clientes (nombre, ciudad) VALUES
    ('Constructora Pacífico S.A.S.', 'Cali'),
    ('Jorge Iván Lasso',             'Cali'),
    ('Clínica Santa Rita',           'Palmira'),
    ('María Fernanda Ortiz',         'Buenaventura'),
    ('Taller Los Andes',             'Yumbo');

INSERT INTO procesos (id_cliente, id_abogado, tipo, estado, fecha_inicio, honorarios) VALUES
    (2, 1, 'Reintegro laboral',            'Activo',     '2026-02-10', 3500000),
    (4, 2, 'Tutela de salud',              'Terminado',  '2026-03-05', 1200000),
    (3, 3, 'Proceso disciplinario',        'Activo',     '2026-04-18', 4800000),
    (1, 1, 'Liquidación de prestaciones',  'Terminado',  '2026-05-22', 2900000),
    (2, 2, 'Derecho de petición',          'Terminado',  '2026-06-30',  600000),
    (1, 3, 'Defensa disciplinaria',        'Suspendido', '2026-08-12', 3100000);

INSERT INTO proyectos (nombre, ciudad, presupuesto, estado) VALUES
    ('Puente Río Cauca',          'Cali',     1850000000, 'En ejecución'),
    ('Edificio Torre Sur',        'Cali',      920000000, 'En ejecución'),
    ('Acueducto Rural La Cumbre', 'Dagua',     410000000, 'Terminado'),
    ('Vía Alterna Jamundí',       'Jamundí',  1300000000, 'Planeado');

INSERT INTO ensayos (id_proyecto, material, resistencia_mpa, fecha) VALUES
    (1, 'Concreto 28 MPa',  29.40, '2026-03-14'),
    (1, 'Concreto 28 MPa',  27.10, '2026-04-02'),
    (1, 'Acero de refuerzo', 420.00, '2026-04-20'),
    (2, 'Concreto 21 MPa',  22.50, '2026-05-11'),
    (2, 'Concreto 21 MPa',  19.80, '2026-06-01'),
    (3, 'Concreto 21 MPa',  23.10, '2026-01-15');

INSERT INTO empleados (nombre, cargo, salario, id_jefe, fecha_ingreso) VALUES
    ('Carolina Muñoz',   'Gerente',        9500000, NULL, '2019-01-15'),
    ('Daniel Barona',    'Jefe de ventas', 6200000, 1,    '2020-03-01'),
    ('Valentina Ruiz',   'Vendedor',       3200000, 2,    '2022-07-11'),
    ('Santiago Mora',    'Vendedor',       3000000, 2,    '2023-02-20'),
    ('Isabel Cárdenas',  'Contador',       5100000, 1,    '2021-05-03');

INSERT INTO productos (nombre, precio, stock) VALUES
    ('Monitor 24"',        620000, 15),
    ('Teclado mecánico',   210000, 40),
    ('Mouse inalámbrico',   85000, 60),
    ('Silla ergonómica',   780000,  8),
    ('Cable HDMI',          25000,  0);

INSERT INTO ventas (id_empleado, id_producto, cantidad, fecha) VALUES
    (3, 1,  2, '2026-10-02'),
    (3, 3, 10, '2026-10-05'),
    (4, 2,  3, '2026-10-07'),
    (4, 4,  1, '2026-10-12'),
    (3, 2,  5, '2026-11-03'),
    (4, 1,  1, '2026-11-08'),
    (2, 4,  2, '2026-11-15');


-- =====================================================================
--  E01. SELECT  (esencial)
--  Pedirle datos a una tabla.
-- =====================================================================

-- Todas las columnas (útil para explorar, evítalo en producción)
SELECT * FROM pacientes;

-- Solo las columnas que necesito
SELECT nombre, ciudad FROM pacientes;

-- Alias con AS y una columna calculada
SELECT nombre AS proyecto,
       presupuesto / 1000000 AS presupuesto_en_millones
FROM proyectos;

-- DISTINCT: valores sin repetir
SELECT DISTINCT ciudad FROM pacientes;
SELECT DISTINCT estado FROM procesos;


-- =====================================================================
--  E02. WHERE  (esencial)
--  Filtrar filas con condiciones.
-- =====================================================================

-- Comparación simple (MEDICINA)
SELECT nombre, ciudad FROM pacientes WHERE ciudad = 'Cali';

-- AND / OR (DERECHO)
SELECT tipo, estado, honorarios
FROM procesos
WHERE estado = 'Activo' AND honorarios > 3000000;

-- BETWEEN e IN (INGENIERÍA)
SELECT material, resistencia_mpa
FROM ensayos
WHERE resistencia_mpa BETWEEN 20 AND 30;

SELECT nombre, estado
FROM proyectos
WHERE estado IN ('En ejecución', 'Planeado');

-- LIKE: búsqueda por patrón (% = cualquier cantidad de letras)
SELECT nombre FROM empleados WHERE nombre LIKE 'S%';
SELECT diagnostico FROM consultas WHERE diagnostico LIKE '%Control%';

-- IS NULL: ojo, NO se escribe "= NULL"
SELECT nombre FROM pacientes WHERE eps IS NULL;
SELECT nombre FROM empleados WHERE id_jefe IS NOT NULL;


-- =====================================================================
--  E03. ORDER BY y LIMIT  (esencial)
--  Ordenar y quedarse con los primeros resultados.
-- =====================================================================

SELECT nombre, salario FROM empleados ORDER BY salario DESC;

-- Ordenar por dos criterios
SELECT ciudad, nombre FROM pacientes ORDER BY ciudad ASC, nombre ASC;

-- Los 3 procesos con mayores honorarios
SELECT tipo, honorarios FROM procesos ORDER BY honorarios DESC LIMIT 3;

-- Paginación: saltar 2 filas y traer las siguientes 2
SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 2 OFFSET 2;


-- =====================================================================
--  E04. FUNCIONES DE AGREGACIÓN  (esencial)
--  COUNT, SUM, AVG, MIN, MAX: muchas filas -> un solo resultado.
-- =====================================================================

-- MEDICINA
SELECT COUNT(*)   AS total_consultas,
       SUM(valor) AS recaudo_total,
       AVG(valor) AS valor_promedio,
       MIN(valor) AS la_mas_barata,
       MAX(valor) AS la_mas_cara
FROM consultas;

-- DERECHO
SELECT SUM(honorarios) AS honorarios_activos
FROM procesos
WHERE estado = 'Activo';

-- INGENIERÍA
SELECT MIN(resistencia_mpa) AS minima, MAX(resistencia_mpa) AS maxima
FROM ensayos
WHERE material LIKE 'Concreto%';

-- ADMINISTRACIÓN
SELECT COUNT(*) AS empleados, ROUND(AVG(salario), 0) AS salario_promedio
FROM empleados;

-- COUNT(*) cuenta filas; COUNT(columna) ignora los NULL
SELECT COUNT(*) AS pacientes, COUNT(eps) AS pacientes_con_eps FROM pacientes;


-- =====================================================================
--  E05. GROUP BY y HAVING  (esencial)
--  Agrupar y resumir por categoría.
-- =====================================================================

-- MEDICINA: consultas y recaudo por diagnóstico
SELECT diagnostico, COUNT(*) AS cantidad, SUM(valor) AS total
FROM consultas
GROUP BY diagnostico
ORDER BY total DESC;

-- DERECHO: procesos y honorarios por estado
SELECT estado, COUNT(*) AS procesos, SUM(honorarios) AS honorarios
FROM procesos
GROUP BY estado;

-- INGENIERÍA: resistencia promedio por material
SELECT material, ROUND(AVG(resistencia_mpa), 2) AS promedio
FROM ensayos
GROUP BY material;

-- ADMINISTRACIÓN: unidades vendidas por mes
SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, SUM(cantidad) AS unidades
FROM ventas
GROUP BY DATE_FORMAT(fecha, '%Y-%m')
ORDER BY mes;

-- HAVING filtra GRUPOS (WHERE filtra filas ANTES de agrupar)
SELECT diagnostico, COUNT(*) AS cantidad
FROM consultas
GROUP BY diagnostico
HAVING COUNT(*) >= 2;


-- =====================================================================
--  E06. JOIN  (esencial)
--  Combinar tablas a través de sus llaves foráneas.
-- =====================================================================

-- INNER JOIN: solo las filas que tienen pareja (MEDICINA)
SELECT p.nombre AS paciente, m.nombre AS medico, c.fecha, c.diagnostico
FROM consultas c
INNER JOIN pacientes p ON p.id_paciente = c.id_paciente
INNER JOIN medicos   m ON m.id_medico   = c.id_medico
ORDER BY c.fecha;

-- LEFT JOIN: todos los de la izquierda, tengan pareja o no (DERECHO)
-- Taller Los Andes aparece con NULL porque no tiene procesos.
SELECT cl.nombre AS cliente, pr.tipo, pr.estado
FROM clientes cl
LEFT JOIN procesos pr ON pr.id_cliente = cl.id_cliente
ORDER BY cl.nombre;

-- Encontrar los que NO tienen relación: LEFT JOIN + IS NULL (MEDICINA)
SELECT p.nombre AS paciente_sin_consultas
FROM pacientes p
LEFT JOIN consultas c ON c.id_paciente = p.id_paciente
WHERE c.id_consulta IS NULL;

-- JOIN + GROUP BY (INGENIERÍA): ensayos por proyecto
SELECT pr.nombre AS proyecto, COUNT(e.id_ensayo) AS ensayos
FROM proyectos pr
LEFT JOIN ensayos e ON e.id_proyecto = pr.id_proyecto
GROUP BY pr.id_proyecto, pr.nombre;

-- JOIN de varias tablas (ADMINISTRACIÓN): ventas por vendedor
SELECT em.nombre AS vendedor,
       SUM(v.cantidad * pd.precio) AS total_vendido
FROM ventas v
JOIN empleados em ON em.id_empleado = v.id_empleado
JOIN productos pd ON pd.id_producto = v.id_producto
GROUP BY em.id_empleado, em.nombre
ORDER BY total_vendido DESC;

-- Autojoin: una tabla unida consigo misma (empleado y su jefe)
SELECT e.nombre AS empleado, j.nombre AS jefe
FROM empleados e
LEFT JOIN empleados j ON j.id_empleado = e.id_jefe;


-- =====================================================================
--  E07, E08 y E09: INSERT, UPDATE y DELETE  (esenciales)
--
--  Estas tres instrucciones MODIFICAN los datos. Para practicar sin
--  dañar la base, cada ejemplo va dentro de una transacción que se
--  deshace con ROLLBACK. (Las transacciones se explican en E15.)
--  Si quieres que el cambio sea permanente, cambia ROLLBACK por COMMIT.
-- =====================================================================

-- ---------- E07. INSERT ----------
START TRANSACTION;

-- Indicando las columnas (la forma recomendada)
INSERT INTO pacientes (nombre, fecha_nacimiento, ciudad, eps)
VALUES ('Carlos Andrés Gil', '1985-12-01', 'Cali', 'Sura');

-- Varias filas a la vez
INSERT INTO clientes (nombre, ciudad) VALUES
    ('Panadería El Trigal', 'Cali'),
    ('Ferretería Central',  'Palmira');

-- Insertar con el resultado de un SELECT
INSERT INTO procesos (id_cliente, id_abogado, tipo, estado, fecha_inicio, honorarios)
SELECT id_cliente, 1, 'Asesoría laboral inicial', 'Activo', CURDATE(), 500000
FROM clientes
WHERE nombre = 'Taller Los Andes';

SELECT * FROM pacientes ORDER BY id_paciente DESC LIMIT 2;
SELECT * FROM procesos  ORDER BY id_proceso  DESC LIMIT 1;
ROLLBACK;

-- ---------- E08. UPDATE ----------
START TRANSACTION;

-- Subir 10 % el salario de los vendedores
UPDATE empleados
SET salario = salario * 1.10
WHERE cargo = 'Vendedor';

-- Cambiar varias columnas a la vez
UPDATE procesos
SET estado = 'Terminado', honorarios = honorarios + 200000
WHERE id_proceso = 3;

SELECT nombre, cargo, salario FROM empleados WHERE cargo = 'Vendedor';
SELECT id_proceso, estado, honorarios FROM procesos WHERE id_proceso = 3;
ROLLBACK;

-- ¡CUIDADO! UPDATE sin WHERE modifica TODAS las filas de la tabla.

-- ---------- E09. DELETE ----------
START TRANSACTION;

-- Borrar una fila concreta (esta consulta no tiene hijos, sí se puede)
DELETE FROM consultas WHERE id_consulta = 5;

-- Borrar por condición
DELETE FROM ensayos WHERE resistencia_mpa < 20;

SELECT COUNT(*) AS consultas_restantes FROM consultas;
SELECT COUNT(*) AS ensayos_restantes   FROM ensayos;
ROLLBACK;

-- Borrar una fila "padre" que tiene "hijos" FALLA por la llave foránea:
--   DELETE FROM pacientes WHERE id_paciente = 1;
--   -> ERROR 1451: Cannot delete or update a parent row
-- Primero hay que borrar (o reasignar) las filas hijas.

-- ¡CUIDADO! DELETE sin WHERE vacía TODA la tabla.


-- =====================================================================
--  E10. SUBCONSULTAS  (no esencial)
--  Una consulta dentro de otra.
-- =====================================================================

-- Subconsulta escalar: consultas más caras que el promedio (MEDICINA)
SELECT diagnostico, valor
FROM consultas
WHERE valor > (SELECT AVG(valor) FROM consultas);

-- Subconsulta con IN: clientes que tienen algún proceso activo (DERECHO)
SELECT nombre
FROM clientes
WHERE id_cliente IN (SELECT id_cliente FROM procesos WHERE estado = 'Activo');

-- NOT EXISTS: proyectos sin ningún ensayo (INGENIERÍA)
SELECT nombre
FROM proyectos pr
WHERE NOT EXISTS (SELECT 1 FROM ensayos e WHERE e.id_proyecto = pr.id_proyecto);

-- Subconsulta en FROM (tabla derivada): empleados que ganan más que el promedio
SELECT e.nombre, e.salario, t.promedio
FROM empleados e
CROSS JOIN (SELECT AVG(salario) AS promedio FROM empleados) t
WHERE e.salario > t.promedio;

-- Subconsulta correlacionada: producto más vendido en unidades
SELECT nombre
FROM productos p
WHERE (SELECT COALESCE(SUM(cantidad), 0) FROM ventas v WHERE v.id_producto = p.id_producto)
    = (SELECT MAX(total)
       FROM (SELECT SUM(cantidad) AS total FROM ventas GROUP BY id_producto) x);


-- =====================================================================
--  E11. CASE Y FUNCIONES DE TEXTO, FECHA Y NULOS  (no esencial)
-- =====================================================================

-- CASE: condicionales dentro de la consulta (INGENIERÍA)
SELECT material, resistencia_mpa,
       CASE
           WHEN material LIKE 'Concreto 28%' AND resistencia_mpa >= 28 THEN 'Cumple'
           WHEN material LIKE 'Concreto 21%' AND resistencia_mpa >= 21 THEN 'Cumple'
           WHEN material LIKE 'Concreto%'                              THEN 'No cumple'
           ELSE 'No aplica'
       END AS resultado
FROM ensayos;

-- Texto: CONCAT, UPPER, LENGTH (DERECHO)
SELECT CONCAT(UPPER(nombre), ' - ', ciudad) AS cliente_ciudad,
       LENGTH(nombre) AS letras
FROM clientes;

-- Fechas: edad con TIMESTAMPDIFF y formato con DATE_FORMAT (MEDICINA)
SELECT nombre,
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad,
       DATE_FORMAT(fecha_nacimiento, '%d/%m/%Y')        AS nacimiento
FROM pacientes
ORDER BY edad DESC;

-- Antigüedad de los empleados en años (ADMINISTRACIÓN)
SELECT nombre, TIMESTAMPDIFF(YEAR, fecha_ingreso, CURDATE()) AS anios_en_la_empresa
FROM empleados;

-- Nulos: IFNULL / COALESCE reemplaza el NULL por un valor
SELECT nombre, IFNULL(eps, 'Sin EPS') AS eps FROM pacientes;
SELECT e.nombre, COALESCE(j.nombre, '(sin jefe)') AS jefe
FROM empleados e
LEFT JOIN empleados j ON j.id_empleado = e.id_jefe;


-- =====================================================================
--  E12. VISTAS  (no esencial)
--  Una consulta guardada con nombre, que se usa como si fuera tabla.
-- =====================================================================

CREATE OR REPLACE VIEW v_historial_consultas AS
SELECT c.id_consulta, p.nombre AS paciente, m.nombre AS medico,
       m.especialidad, c.fecha, c.diagnostico, c.valor
FROM consultas c
JOIN pacientes p ON p.id_paciente = c.id_paciente
JOIN medicos   m ON m.id_medico   = c.id_medico;

CREATE OR REPLACE VIEW v_carga_abogados AS
SELECT a.nombre AS abogado, a.area,
       COUNT(pr.id_proceso)          AS procesos,
       COALESCE(SUM(pr.honorarios), 0) AS honorarios
FROM abogados a
LEFT JOIN procesos pr ON pr.id_abogado = a.id_abogado
GROUP BY a.id_abogado, a.nombre, a.area;

-- Se consultan igual que una tabla
SELECT * FROM v_historial_consultas WHERE especialidad = 'Geriatría';
SELECT * FROM v_carga_abogados ORDER BY honorarios DESC;

-- Para borrar una vista: DROP VIEW v_carga_abogados;


-- =====================================================================
--  E13. ÍNDICES  (no esencial)
--  Aceleran las búsquedas en tablas grandes.
-- =====================================================================

CREATE INDEX idx_consultas_fecha  ON consultas (fecha);
CREATE INDEX idx_procesos_estado  ON procesos (estado, fecha_inicio);  -- índice compuesto
CREATE UNIQUE INDEX idx_productos_nombre ON productos (nombre);        -- no permite nombres repetidos

-- Ver los índices de una tabla
SHOW INDEX FROM consultas;

-- EXPLAIN muestra si MySQL usa el índice (mira la columna "key")
EXPLAIN SELECT * FROM consultas WHERE fecha >= '2026-10-01';

-- Las llaves primarias y foráneas ya crean índices automáticamente.
-- Los índices aceleran SELECT pero hacen más lentos INSERT/UPDATE/DELETE:
-- se crean solo donde se busca o se une con frecuencia.


-- =====================================================================
--  E14. PROCEDIMIENTOS ALMACENADOS Y TRIGGERS  (no esencial)
--  Lógica guardada dentro de la base de datos.
-- =====================================================================

DELIMITER $$

-- Procedimiento con un parámetro de entrada (MEDICINA)
DROP PROCEDURE IF EXISTS sp_consultas_de_paciente$$
CREATE PROCEDURE sp_consultas_de_paciente(IN p_id_paciente INT)
BEGIN
    SELECT c.fecha, m.nombre AS medico, c.diagnostico, c.valor
    FROM consultas c
    JOIN medicos m ON m.id_medico = c.id_medico
    WHERE c.id_paciente = p_id_paciente
    ORDER BY c.fecha;
END$$

-- Procedimiento con parámetro de salida (ADMINISTRACIÓN)
DROP PROCEDURE IF EXISTS sp_total_vendido_por_empleado$$
CREATE PROCEDURE sp_total_vendido_por_empleado(
    IN  p_id_empleado INT,
    OUT p_total       DECIMAL(15,2))
BEGIN
    SELECT COALESCE(SUM(v.cantidad * pd.precio), 0)
      INTO p_total
    FROM ventas v
    JOIN productos pd ON pd.id_producto = v.id_producto
    WHERE v.id_empleado = p_id_empleado;
END$$

DELIMITER ;

CALL sp_consultas_de_paciente(1);
CALL sp_total_vendido_por_empleado(3, @total);
SELECT @total AS total_vendido_por_valentina;

-- Trigger: se dispara solo cuando ocurre un evento en la tabla.
-- Aquí guardamos un historial cada vez que cambia el precio de un producto.
CREATE TABLE auditoria_precios (
    id_auditoria    INT AUTO_INCREMENT PRIMARY KEY,
    id_producto     INT           NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    cambiado_en     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

DROP TRIGGER IF EXISTS trg_auditar_precio$$
CREATE TRIGGER trg_auditar_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (id_producto, precio_anterior, precio_nuevo)
        VALUES (OLD.id_producto, OLD.precio, NEW.precio);
    END IF;
END$$

DELIMITER ;

-- Probar el trigger (dentro de una transacción para no alterar los datos)
START TRANSACTION;
UPDATE productos SET precio = 650000 WHERE nombre = 'Monitor 24"';
SELECT * FROM auditoria_precios;
ROLLBACK;


-- =====================================================================
--  E15. TRANSACCIONES  (no esencial)
--  Varias instrucciones que se ejecutan completas o no se ejecutan.
--  Propiedades ACID: Atomicidad, Consistencia, Aislamiento, Durabilidad.
-- =====================================================================

-- Caso 1: una venta correcta. Se registra la venta Y se descuenta el stock.
-- Si algo falla a mitad de camino, no puede quedar una sin la otra.
START TRANSACTION;

INSERT INTO ventas (id_empleado, id_producto, cantidad, fecha)
VALUES (3, 1, 2, CURDATE());

UPDATE productos
SET stock = stock - 2
WHERE id_producto = 1;

COMMIT;   -- confirma: los cambios ya son permanentes

SELECT nombre, stock FROM productos WHERE id_producto = 1;   -- 13

-- Caso 2: algo sale mal -> ROLLBACK deshace todo.
START TRANSACTION;

UPDATE productos SET stock = stock - 100 WHERE id_producto = 4;
SELECT nombre, stock FROM productos WHERE id_producto = 4;   -- -92: ¡error lógico!

ROLLBACK; -- se descarta el cambio

SELECT nombre, stock FROM productos WHERE id_producto = 4;   -- vuelve a 8

-- Caso 3: SAVEPOINT permite deshacer solo una parte.
START TRANSACTION;

UPDATE empleados SET salario = salario + 100000 WHERE id_empleado = 3;
SAVEPOINT despues_del_primer_aumento;

UPDATE empleados SET salario = salario + 100000 WHERE id_empleado = 4;
ROLLBACK TO despues_del_primer_aumento;   -- deshace solo el aumento del empleado 4

COMMIT;   -- confirma solo el aumento del empleado 3

SELECT id_empleado, nombre, salario FROM empleados WHERE id_empleado IN (3, 4);

-- =====================================================================
--  FIN DEL SCRIPT
-- =====================================================================
