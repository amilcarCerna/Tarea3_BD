/*
CREATE TABLE PUESTO (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    bono DECIMAL(12,2),
    salario DECIMAL(12,2)
);
go

CREATE TABLE EMPLEADO (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    fecha_inicio DATE,
    puesto INT,
    CONSTRAINT fk_puesto FOREIGN KEY (puesto) REFERENCES PUESTO(id)
);
go
*/

/*
-- Insertar datos en la tabla PUESTO
INSERT INTO PUESTO (nombre, bono, salario) VALUES 
('Gerente', 1000.00, 5000.00),
('Asistente', 500.00, 3000.00),
('Analista', 750.00, 4000.00),
('Técnico', 300.00, 2000.00),
('Operario', 200.00, 1500.00);
go
-- Insertar datos en la tabla EMPLEADO
-- Asume que la fecha de inicio es variada para probar los diferentes bonos
INSERT INTO EMPLEADO (nombre, fecha_inicio, puesto) VALUES 
('Juan Perez', '2022-01-15', 1), -- Gerente que empezó hace menos de un año
('Ana Gomez', '2020-03-10', 2), -- Asistente que empezó hace más de 1 año pero menos de 3
('Carlos Ruiz', '2019-06-20', 3), -- Analista que empezó hace más de 3 años pero menos de 5
('Lucia Méndez', '2017-02-25', 4), -- Técnico que empezó hace más de 5 años pero menos de 8
('Mario Borges', '2014-08-30', 5); -- Operario que empezó hace más de 8 años
*/

-- Crear tabla temporal para almacenar la planilla de empleados
CREATE TABLE #Planilla (
    Nombre VARCHAR(50),
    SalarioTotal DECIMAL(12,2)
);

-- Declarar variables para el cursor
DECLARE @nombre VARCHAR(50), @fecha_inicio DATE, @bono DECIMAL(12,2), @salario DECIMAL(12,2), @anios_servicio INT, @salario_total DECIMAL(12,2), @idPuesto INT;

-- Declarar el cursor
DECLARE empleados_cursor CURSOR FOR
SELECT E.nombre, E.fecha_inicio, P.bono, P.salario, E.puesto
FROM EMPLEADO E
   INNER JOIN PUESTO P 
      ON E.puesto = P.id;

-- Abrir cursor y obtener la primera fila
OPEN empleados_cursor;
FETCH NEXT FROM empleados_cursor INTO @nombre, @fecha_inicio, @bono, @salario, @idPuesto;

-- Iterar a través del cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Años de servicio
    SET @anios_servicio = DATEDIFF(YEAR, @fecha_inicio, GETDATE());
    
    -- Calcula salario
    IF @anios_servicio BETWEEN 0 AND 1
        SET @salario_total = @salario;
    ELSE IF @anios_servicio BETWEEN 1 AND 3
        SET @salario_total = @salario + (@bono * 0.10);
    ELSE IF @anios_servicio BETWEEN 3 AND 5
        SET @salario_total = @salario + (@bono * 0.25);
    ELSE IF @anios_servicio BETWEEN 5 AND 8
        SET @salario_total = @salario + (@bono * 0.50);
    ELSE IF @anios_servicio >= 8
        SET @salario_total = @salario + @bono;
    
    -- Insertar en la tabla temporal #Planilla
    INSERT INTO #Planilla (Nombre, SalarioTotal) VALUES (@nombre, @salario_total);
    
    -- Obtener la siguiente fila
    FETCH NEXT FROM empleados_cursor INTO @nombre, @fecha_inicio, @bono, @salario, @idPuesto;
END

-- Cerrar y liberar el cursor
CLOSE empleados_cursor;
DEALLOCATE empleados_cursor;

/***************************************************/
-- Prueba de datos almacenados en tabla #Planilla
SELECT * FROM #Planilla;


