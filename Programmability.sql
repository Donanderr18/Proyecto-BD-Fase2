-- Programmability

-- Funciones

-- fn_calcular_impuesto

CREATE OR ALTER FUNCTION fn_calcular_impuesto (@monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS 
BEGIN
    RETURN @monto * 0.16; -- IVA 16%
END;
GO

-- fn_precio_con_descuento

CREATE OR ALTER FUNCTION fn_precio_con_descuento (@ID_Producto INT, @fecha DATETIME2)
RETURNS DECIMAL(10,2)
AS 
BEGIN
    DECLARE @precio DECIMAL(10,2), @descuento DECIMAL(5,2) = 0;
    
    SELECT @precio = Precio_Base_Actual FROM Producto_Digital WHERE ID_Producto = @ID_Producto;
    
    SELECT TOP 1 @descuento = Porcentaje_Descuento 
    FROM Historial_Descuento
    WHERE ID_Producto = @ID_Producto AND @fecha BETWEEN Fecha_Inicio AND Fecha_Fin
    ORDER BY Porcentaje_Descuento DESC;       -- Toma el mejor descuento si hay solapamiento
    
    RETURN @precio - (@precio * (@descuento / 100.0));
END;
GO

-- fn_clasificar_ingreso

CREATE OR ALTER FUNCTION fn_clasificar_ingreso (@monto DECIMAL(15,2))
RETURNS NVARCHAR(20)
AS 
BEGIN
    IF @monto > 10000 RETURN 'AAA';
    IF @monto >= 2000 RETURN 'Consolidado';
    RETURN 'Indie';
END;
GO

-- fn_calcular_reputacion

CREATE OR ALTER FUNCTION fn_calcular_reputacion (@ID_Producto INT)
RETURNS DECIMAL(5,2)
AS 
BEGIN
    DECLARE @promedio DECIMAL(5,2) = 0, @meta INT = 0, @jugadores INT = 0, @reputacion DECIMAL(5,2);
    
    SELECT @promedio = ISNULL(AVG(CAST(Calificacion_1_10 AS DECIMAL(5,2))), 0) 
    FROM Resena WHERE ID_Producto = @ID_Producto;
    
    SELECT @meta = ISNULL(Metacritic_Score, 0) 
    FROM Producto_Digital WHERE ID_Producto = @ID_Producto;
    
    SELECT @jugadores = COUNT(DISTINCT ID_Usuario) 
    FROM Biblioteca WHERE ID_Producto = @ID_Producto;

    SET @reputacion = (@promedio * 7) + (@meta * 0.2) + (@jugadores * 0.05);
    
    IF @reputacion > 100 SET @reputacion = 100.00;
    
    RETURN @reputacion;
END;
GO

-- fn_calcular_horas_totales_usuario

CREATE OR ALTER FUNCTION fn_calcular_horas_totales_usuario (@ID_Usuario INT)
RETURNS DECIMAL(10,2)
AS 
BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = ISNULL(SUM(Horas_Jugadas), 0.0) 
    FROM Biblioteca WHERE ID_Usuario = @ID_Usuario;
    RETURN @total;
END;
GO

-- Procedimientos

-- sp_realizar_compra

CREATE OR ALTER PROCEDURE sp_realizar_compra
    @ID_Usuario INT,
    @ID_Metodo_Pago INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        
        IF NOT EXISTS (SELECT 1 FROM Carrito WHERE ID_Usuario = @ID_Usuario) -- Carrito vacio
            THROW 50001, 'El carrito está vacío.', 1;

        IF EXISTS (                                                         --  Que no posea ya los juegos
            SELECT 1 FROM Carrito C 
            INNER JOIN Biblioteca B ON C.ID_Producto = B.ID_Producto 
            WHERE C.ID_Usuario = @ID_Usuario AND B.ID_Usuario = @ID_Usuario
        ) THROW 50002, 'El usuario ya posee uno o más productos del carrito.', 1;

        DECLARE @ID_Factura INT;
        DECLARE @Sub_Total DECIMAL(10,2) = 0;
        DECLARE @Monto_Impuesto DECIMAL(10,2) = 0;
        DECLARE @Total_Pagado DECIMAL(10,2) = 0;
        DECLARE @Fecha_Actual DATETIME2 = GETDATE();
        DECLARE @Codigo_Tx VARCHAR(50) = NEWID();

        SELECT @Sub_Total = SUM(dbo.fn_precio_con_descuento(ID_Producto, @Fecha_Actual))
        FROM Carrito WHERE ID_Usuario = @ID_Usuario;
        
        SET @Monto_Impuesto = dbo.fn_calcular_impuesto(@Sub_Total);
        SET @Total_Pagado = @Sub_Total + @Monto_Impuesto; -- Asumiendo descuento ya aplicado en el precio efectivo

        INSERT INTO Factura (Codigo_Transaccion, Fecha_Hora_Emision, Sub_Total, Monto_Descuento, Monto_Impuesto, Total_Pagado, ID_Usuario, ID_Metodo_Pago)
        VALUES (@Codigo_Tx, @Fecha_Actual, @Sub_Total, 0, @Monto_Impuesto, @Total_Pagado, @ID_Usuario, @ID_Metodo_Pago);
        
        SET @ID_Factura = SCOPE_IDENTITY();

        INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Precio_Venta_Historico, Descuento_Aplicado_Pct)
        SELECT 
            @ID_Factura,     
            C.ID_Producto, 
            dbo.fn_precio_con_descuento(C.ID_Producto, @Fecha_Actual),
            ISNULL((SELECT TOP 1 Porcentaje_Descuento FROM Historial_Descuento WHERE ID_Producto = C.ID_Producto AND @Fecha_Actual BETWEEN Fecha_Inicio AND Fecha_Fin ORDER BY Porcentaje_Descuento DESC), 0)
        FROM Carrito C WHERE C.ID_Usuario = @ID_Usuario;

        DELETE FROM Carrito WHERE ID_Usuario = @ID_Usuario;        -- Vaciar Carrito

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- sp_dashboard_estudio

CREATE OR ALTER PROCEDURE sp_dashboard_estudio
    @ID_Empresa INT,
    @Fecha_Inicio DATETIME2,
    @Fecha_Fin DATETIME2
AS
BEGIN

    SELECT 
        ISNULL(SUM(DF.Precio_Venta_Historico), 0) AS Ingreso_Total,
        COUNT(DF.ID_Producto) AS Unidades_Vendidas,
        (SELECT COUNT(*) FROM Reembolso R INNER JOIN Juego_Base JB ON R.ID_Producto = JB.ID_Producto WHERE JB.ID_Estudio_Dev = @ID_Empresa AND R.Fecha_Reembolso BETWEEN @Fecha_Inicio AND @Fecha_Fin) AS Reembolsos_Periodo
    FROM Detalle_Factura DF
    INNER JOIN Factura F ON DF.ID_Factura = F.ID_Factura
    INNER JOIN Juego_Base JB ON DF.ID_Producto = JB.ID_Producto
    WHERE JB.ID_Estudio_Dev = @ID_Empresa AND F.Fecha_Hora_Emision BETWEEN @Fecha_Inicio AND @Fecha_Fin;

    -- Top 5 juegos vendidos

    SELECT TOP 5 PD.Titulo, COUNT(DF.ID_Producto) AS Vendidos
    FROM Detalle_Factura DF
    INNER JOIN Factura F ON DF.ID_Factura = F.ID_Factura
    INNER JOIN Juego_Base JB ON DF.ID_Producto = JB.ID_Producto
    INNER JOIN Producto_Digital PD ON JB.ID_Producto = PD.ID_Producto
    WHERE JB.ID_Estudio_Dev = @ID_Empresa AND F.Fecha_Hora_Emision BETWEEN @Fecha_Inicio AND @Fecha_Fin
    GROUP BY PD.Titulo
    ORDER BY Vendidos DESC;

    -- Top 5 compradores

    SELECT TOP 5 U.Nickname, SUM(DF.Precio_Venta_Historico) AS Gasto_Total
    FROM Detalle_Factura DF
    INNER JOIN Factura F ON DF.ID_Factura = F.ID_Factura
    INNER JOIN Juego_Base JB ON DF.ID_Producto = JB.ID_Producto
    INNER JOIN Usuario U ON F.ID_Usuario = U.ID_Usuario
    WHERE JB.ID_Estudio_Dev = @ID_Empresa AND F.Fecha_Hora_Emision BETWEEN @Fecha_Inicio AND @Fecha_Fin
    GROUP BY U.Nickname
    ORDER BY Gasto_Total DESC;
END;
GO

-- sp_publicar_producto_con_etiquetas

CREATE OR ALTER PROCEDURE sp_publicar_producto_con_etiquetas
    @Titulo VARCHAR(100), @Desc_Corta VARCHAR(255), @Desc_Larga VARCHAR(MAX),
    @Fecha DATETIME2, @Tamano DECIMAL(6,2), @Clasif VARCHAR(5),
    @Precio DECIMAL(10,2), @Tipo VARCHAR(20), @Meta INT,
    @ID_Estudio INT = NULL, @ID_Publisher INT = NULL, @Motor VARCHAR(50) = NULL,
    @ID_Juego_Base INT = NULL, @Tipo_Contenido VARCHAR(20) = NULL, @Subtipo VARCHAR(20) = NULL,
    @Etiquetas VARCHAR(MAX) 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        
        DECLARE @ID_Prod INT;
        
        INSERT INTO Producto_Digital (Titulo, Descripcion_Corta, Descripcion_Larga, Fecha_Lanzamiento, Tamano_GB, Clasificacion_Edad, Precio_Base_Actual, Tipo_Producto, Metacritic_Score)
        VALUES (@Titulo, @Desc_Corta, @Desc_Larga, @Fecha, @Tamano, @Clasif, @Precio, @Tipo, @Meta);
        
        SET @ID_Prod = SCOPE_IDENTITY();

        IF @Tipo = 'Juego_Base'
            INSERT INTO Juego_Base (ID_Producto, ID_Estudio_Dev, ID_Publisher, Motor_Grafico, Tiene_Compras_InGame, Soporta_Cloud_Saves)
            VALUES (@ID_Prod, @ID_Estudio, @ID_Publisher, @Motor, 0, 1);
        ELSE
            INSERT INTO DLC (ID_Producto, ID_Juego_Base, Tipo_Contenido, Subtipo_Jugable)
            VALUES (@ID_Prod, @ID_Juego_Base, @Tipo_Contenido, @Subtipo);

        DECLARE @Tag VARCHAR(50), @TagID INT; -- Procesar etiquetas 
        DECLARE tag_cursor CURSOR FOR SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@Etiquetas, ',');
        
        OPEN tag_cursor;
        FETCH NEXT FROM tag_cursor INTO @Tag;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Etiqueta_Comunidad WHERE Nombre_Etiqueta = @Tag)
            BEGIN
                INSERT INTO Etiqueta_Comunidad (Nombre_Etiqueta) VALUES (@Tag);
                SET @TagID = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SELECT @TagID = ID_Etiqueta FROM Etiqueta_Comunidad WHERE Nombre_Etiqueta = @Tag;
            END
            
            INSERT INTO Producto_Etiqueta (ID_Producto, ID_Etiqueta, Cantidad_Votos) VALUES (@ID_Prod, @TagID, 1);
            
            FETCH NEXT FROM tag_cursor INTO @Tag;
        END
        CLOSE tag_cursor;
        DEALLOCATE tag_cursor;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- sp_procesar_reembolso

CREATE OR ALTER PROCEDURE sp_procesar_reembolso
    @ID_Factura INT,
    @ID_Producto INT,
    @Motivo VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        
        DECLARE @Fecha_Compra DATETIME2, @Horas_Jugadas DECIMAL(10,2), @Monto DECIMAL(10,2), @ID_Usuario INT;
        
        SELECT @Fecha_Compra = Fecha_Hora_Emision, @ID_Usuario = ID_Usuario FROM Factura WHERE ID_Factura = @ID_Factura;
        SELECT @Horas_Jugadas = Horas_Jugadas FROM Biblioteca WHERE ID_Usuario = @ID_Usuario AND ID_Producto = @ID_Producto;
        SELECT @Monto = Precio_Venta_Historico FROM Detalle_Factura WHERE ID_Factura = @ID_Factura AND ID_Producto = @ID_Producto;
        
        IF DATEDIFF(DAY, @Fecha_Compra, GETDATE()) > 14
            THROW 50003, 'Han pasado más de 14 días desde la compra.', 1;
            
        IF @Horas_Jugadas > 2.0
            THROW 50004, 'El tiempo de juego supera las 2 horas permitidas.', 1;

        INSERT INTO Reembolso (ID_Factura, ID_Producto, Fecha_Reembolso, Monto_Reembolsado, Motivo)
        VALUES (@ID_Factura, @ID_Producto, GETDATE(), @Monto, @Motivo);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- sp_desbloquear_logro

CREATE OR ALTER PROCEDURE sp_desbloquear_logro
    @ID_Usuario INT,
    @ID_Juego_Base INT,
    @ID_Logro INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        
        IF NOT EXISTS (SELECT 1 FROM Logro WHERE ID_Juego_Base = @ID_Juego_Base AND ID_Logro = @ID_Logro)
            THROW 50005, 'El logro no existe o no pertenece a este juego.', 1;
            
        IF NOT EXISTS (SELECT 1 FROM Biblioteca WHERE ID_Usuario = @ID_Usuario AND ID_Producto = @ID_Juego_Base)
            THROW 50006, 'El usuario no posee este juego en su biblioteca.', 1;
            
        IF EXISTS (SELECT 1 FROM Desbloqueo_Logro WHERE ID_Usuario = @ID_Usuario AND ID_Juego_Base = @ID_Juego_Base AND ID_Logro = @ID_Logro)
            THROW 50007, 'El logro ya ha sido desbloqueado.', 1;

        INSERT INTO Desbloqueo_Logro (ID_Usuario, ID_Juego_Base, ID_Logro, Fecha_Desbloqueo)
        VALUES (@ID_Usuario, @ID_Juego_Base, @ID_Logro, GETDATE());

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- Triggers

-- Auditoría de Precios

CREATE OR ALTER TRIGGER TR_Auditoria_Precios
ON Producto_Digital
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Precio_Base_Actual)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            INNER JOIN deleted d ON i.ID_Producto = d.ID_Producto
            WHERE d.Precio_Base_Actual > 0 
            AND ABS((i.Precio_Base_Actual - d.Precio_Base_Actual) / d.Precio_Base_Actual) > 0.50
        )
        BEGIN
            ROLLBACK TRAN;
            RAISERROR('El cambio de precio supera el 50% permitido por auditoría de seguridad.', 16, 1);
        END
    END
END;
GO

-- Protección de Menores 

CREATE OR ALTER TRIGGER TR_Proteccion_Menores
ON Detalle_Factura
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN Factura f ON i.ID_Factura = f.ID_Factura
        INNER JOIN Usuario u ON f.ID_Usuario = u.ID_Usuario
        INNER JOIN Producto_Digital p ON i.ID_Producto = p.ID_Producto
        WHERE p.Clasificacion_Edad IN ('M', 'AO')
        AND DATEDIFF(YEAR, u.Fecha_Nacimiento, f.Fecha_Hora_Emision) < 18
    )
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('Contenido restringido por edad.', 16, 1);
    END
END;
GO

-- Poblado automático de Biblioteca

CREATE OR ALTER TRIGGER TR_Poblar_Biblioteca
ON Detalle_Factura
AFTER INSERT
AS
BEGIN
    INSERT INTO Biblioteca (ID_Usuario, ID_Producto, Horas_Jugadas, Fecha_Ultima_Sesion)
    SELECT f.ID_Usuario, i.ID_Producto, 0, NULL
    FROM inserted i
    INNER JOIN Factura f ON i.ID_Factura = f.ID_Factura
    WHERE NOT EXISTS (
        SELECT 1 FROM Biblioteca b 
        WHERE b.ID_Usuario = f.ID_Usuario AND b.ID_Producto = i.ID_Producto
    );
END;
GO

-- Reembolso = revocación de acceso

CREATE OR ALTER TRIGGER TR_Revocar_Acceso
ON Reembolso
AFTER INSERT
AS
BEGIN
    DELETE b
    FROM Biblioteca b
    INNER JOIN inserted i ON b.ID_Producto = i.ID_Producto
    INNER JOIN Factura f ON i.ID_Factura = f.ID_Factura
    WHERE b.ID_Usuario = f.ID_Usuario;
END;
GO

-- Validaciones de Precompra en Carrito

CREATE OR ALTER TRIGGER TR_Validar_Carrito
ON Carrito
AFTER INSERT
AS
BEGIN
    IF EXISTS (    -- Que no lo tenga en biblioteca
        SELECT 1 FROM inserted i
        INNER JOIN Biblioteca b ON i.ID_Usuario = b.ID_Usuario AND i.ID_Producto = b.ID_Producto
    )
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('El usuario ya posee este producto.', 16, 1);
        RETURN;
    END
    IF EXISTS (      -- Si es DLC, que posea el juego base o esté en el carrito
        SELECT 1 FROM inserted i
        INNER JOIN Producto_Digital p ON i.ID_Producto = p.ID_Producto
        INNER JOIN DLC d ON p.ID_Producto = d.ID_Producto
        WHERE p.Tipo_Producto = 'DLC'
        AND NOT EXISTS (SELECT 1 FROM Biblioteca b WHERE b.ID_Usuario = i.ID_Usuario AND b.ID_Producto = d.ID_Juego_Base)
        AND NOT EXISTS (SELECT 1 FROM Carrito c WHERE c.ID_Usuario = i.ID_Usuario AND c.ID_Producto = d.ID_Juego_Base)
    )
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('Debe poseer el Juego Base o agregarlo al carrito junto con el DLC.', 16, 1);
    END
END;
GO