-- DROP TABLES POR SI SE NECESITA MODIFICAR ALGO

DROP TABLE Empresa_Corporativa;
DROP TABLE Producto_Digital;
DROP TABLE Galeria_Multimedia;
DROP TABLE Juego_Base;
DROP TABLE DLC;
DROP TABLE Perfil_Requisito;
DROP TABLE Logro;
DROP TABLE Categoria_Oficial;
DROP TABLE Juego_Categoria;
DROP TABLE Idioma;
DROP TABLE Soporte_Idioma;
DROP TABLE Etiqueta_Comunidad;
DROP TABLE Producto_Etiqueta;
DROP TABLE Mod;
DROP TABLE Usuario;
DROP TABLE Amistad_Usuario;
DROP TABLE Desbloqueo_Logro;
DROP TABLE Biblioteca;
DROP TABLE Lista_Deseos;
DROP TABLE Carrito;
DROP TABLE Resena;
DROP TABLE Suscripcion_Mod;
DROP TABLE Metodo_Pago;
DROP TABLE Factura;
DROP TABLE Detalle_Factura;
DROP TABLE Reembolso;
DROP TABLE Historial_Descuento;
DROP TABLE Registro_Concurrencia;

-- SELECTS PARA VER COMO VAN QUEDANDO LAS TABLAS

SELECT * FROM Empresa_Corporativa;
SELECT * FROM Producto_Digital;
SELECT * FROM Galeria_Multimedia;
SELECT * FROM Juego_Base;
SELECT * FROM DLC;
SELECT * FROM Perfil_Requisito ;
SELECT * FROM Logro;
SELECT * FROM Categoria_Oficial;
SELECT * FROM Juego_Categoria;
SELECT * FROM Idioma;
SELECT * FROM Soporte_Idioma;
SELECT * FROM Etiqueta_Comunidad;
SELECT * FROM Producto_Etiqueta;
SELECT * FROM Mod;
SELECT * FROM Usuario;
SELECT * FROM Amistad_Usuario;
SELECT * FROM Desbloqueo_Logro;
SELECT * FROM Biblioteca;
SELECT * FROM Lista_Deseos;
SELECT * FROM Carrito;
SELECT * FROM Resena;
SELECT * FROM Suscripcion_Mod;
SELECT * FROM Metodo_Pago;
SELECT * FROM Factura;
SELECT * FROM Detalle_Factura;
SELECT * FROM Reembolso;
SELECT * FROM Historial_Descuento;
SELECT * FROM Registro_Concurrencia;

-- 1

SELECT	Empresa_Corporativa.Nombre AS Estudio,
		Empresa_Corporativa.Pais_Origen AS Pais_Origen,
		COUNT(Detalle_Factura.ID_Producto) AS Juegos_Vendidos,
		CAST (SUM(Detalle_Factura.Precio_Venta_Historico * (1.0 -(Detalle_Factura.Descuento_Aplicado_Pct / 100.0))) AS decimal(10,2))
		AS Ingreso_Total,
		dbo.fn_clasificar_ingreso( SUM(Detalle_Factura.Precio_Venta_Historico * (1.0 -
		(Detalle_Factura.Descuento_Aplicado_Pct / 100.0))) ) AS Clasificacion
FROM Detalle_Factura
JOIN Factura ON Detalle_Factura.ID_Factura = Factura.ID_Factura
JOIN Juego_Base ON Detalle_Factura.ID_Producto = Juego_Base.ID_Producto
JOIN Empresa_Corporativa ON Juego_Base.ID_Estudio_Dev = Empresa_Corporativa.ID_Empresa
WHERE DATEDIFF(MONTH, Factura.Fecha_Hora_Emision, GETDATE()) = 1
GROUP BY Empresa_Corporativa.Nombre, Empresa_Corporativa.Pais_Origen
ORDER BY Ingreso_Total DESC;

-- 2 

WITH EstadisticasProducto AS ( 
    SELECT p.ID_Producto,
           p.Titulo,
           p.Metacritic_Score,
           ec.Nombre AS Estudio,
           (SELECT COUNT(*) FROM Detalle_Factura df WHERE df.ID_Producto = p.ID_Producto) AS Unidades_Vendidas,
           (SELECT COUNT(*) FROM Resena r WHERE r.ID_Producto = p.ID_Producto) AS Total_Resenas
    FROM Producto_Digital p
    LEFT JOIN Juego_Base jb ON p.ID_Producto = jb.ID_Producto
    LEFT JOIN DLC d ON p.ID_Producto = d.ID_Producto
    LEFT JOIN Juego_Base jb2 ON d.ID_Juego_Base = jb2.ID_Producto
    LEFT JOIN Empresa_Corporativa ec ON ISNULL(jb.ID_Estudio_Dev, jb2.ID_Estudio_Dev) = ec.ID_Empresa ),
RankingCategorias AS (
    SELECT co.Nombre_Categoria,
           ep.Titulo,
           ep.Estudio,
           (ep.Unidades_Vendidas * 2.0) + (ep.Total_Resenas * 1.5) + ISNULL(ep.Metacritic_Score, 0) AS Puntaje_Popularidad,
           ROW_NUMBER() OVER( PARTITION BY co.ID_Categoria 
           ORDER BY ((ep.Unidades_Vendidas * 2.0) + (ep.Total_Resenas * 1.5) + ISNULL(ep.Metacritic_Score, 0)) DESC) AS Fila_Ranking
    FROM Categoria_Oficial co
    INNER JOIN Juego_Categoria jc ON co.ID_Categoria = jc.ID_Categoria
    INNER JOIN EstadisticasProducto ep ON jc.ID_Producto = ep.ID_Producto )
SELECT Nombre_Categoria, Titulo, Estudio, Puntaje_Popularidad
FROM RankingCategorias
WHERE Fila_Ranking = 1;

-- 3

SELECT  SUBSTRING(Correo, CHARINDEX('@', Correo) + 1, LEN(Correo)) AS Dominio,
        COUNT(ID_Usuario) AS  Cantidad_Usuarios
FROM Usuario
GROUP BY SUBSTRING(Correo, CHARINDEX('@', Correo) + 1, LEN(Correo))
HAVING COUNT(ID_Usuario) > 10
ORDER BY Cantidad_Usuarios DESC;

-- 4 

SELECT U.Nickname, 
       C1.Fecha_Hora_Emision AS Fecha_Primera_Compra,
       C2.Fecha_Hora_Emision AS Fecha_Segunda_Compra,
       DATEDIFF(DAY, C1.Fecha_Hora_Emision, C2.Fecha_Hora_Emision) AS Dias_Entre_Compras
FROM Usuario U
JOIN ( SELECT ID_Usuario, Fecha_Hora_Emision,
              ROW_NUMBER() OVER(PARTITION BY ID_Usuario ORDER BY Fecha_Hora_Emision) AS Numero_Compra
       FROM Factura) C1 ON U.ID_Usuario = C1.ID_Usuario AND C1.Numero_Compra = 1
JOIN ( SELECT ID_Usuario, Fecha_Hora_Emision,
              ROW_NUMBER() OVER(PARTITION BY ID_Usuario ORDER BY Fecha_Hora_Emision) AS Numero_Compra
       FROM Factura) C2 ON U.ID_Usuario = C2.ID_Usuario AND C2.Numero_Compra = 2
WHERE DATEDIFF(DAY, C1.Fecha_Hora_Emision, C2.Fecha_Hora_Emision) <= 30;

-- 5

SELECT  Empresa_Corporativa.Nombre AS  Estudio,
        COUNT (Juego_Base.ID_Producto) AS Cantidad_Juegos,
        CASE 
            WHEN SUM(Producto_Digital.Tamano_GB) >= 1024 THEN CAST(CAST( SUM(Producto_Digital.Tamano_GB) / 1024.0 AS decimal(10,2)) AS varchar) + ' TB'
            ELSE CAST(CAST(SUM(Producto_Digital.Tamano_GB) AS decimal(10,2)) AS varchar) + ' GB'
        END AS Peso_Total
FROM Juego_Base
JOIN Empresa_Corporativa ON Juego_Base.ID_Estudio_Dev = Empresa_Corporativa.ID_Empresa
JOIN Producto_Digital ON Juego_Base.ID_Producto = Producto_Digital.ID_Producto
GROUP BY Empresa_Corporativa.Nombre
ORDER BY SUM(Producto_Digital.Tamano_GB) DESC;

-- 6 

SELECT NP.Pais, 
       NP.Total_Neto, 
       CAST(CAST((NP.Total_Neto / TM.Total_Global) * 100 AS DECIMAL(5,1)) AS VARCHAR) + '%' AS Share
FROM ( SELECT U.Pais_Residencia AS Pais, SUM(F.Total_Pagado) - ISNULL((SELECT SUM(R.Monto_Reembolsado) 
       FROM Reembolso R 
       JOIN Factura F2 ON R.ID_Factura = F2.ID_Factura 
       JOIN Usuario U2 ON F2.ID_Usuario = U2.ID_Usuario 
       WHERE U2.Pais_Residencia = U.Pais_Residencia), 0) AS Total_Neto
       FROM Usuario U
       JOIN Factura F ON U.ID_Usuario = F.ID_Usuario
       GROUP BY U.Pais_Residencia) NP
CROSS JOIN ( SELECT SUM(Total_Pagado) - ISNULL((SELECT SUM(Monto_Reembolsado) FROM Reembolso), 0) AS Total_Global 
             FROM Factura ) TM;

-- 7 

SELECT  Usuario.Nickname, 
        SUM(Factura.Total_Pagado) AS Gasto_Total_Historico
FROM Usuario 
JOIN Factura ON Usuario.ID_Usuario = Factura.ID_Usuario
WHERE EXISTS (
        SELECT 1 FROM Biblioteca  
        JOIN Juego_Categoria ON Biblioteca.ID_Producto = Juego_Categoria.ID_Producto
        JOIN Categoria_Oficial  ON Juego_Categoria.ID_Categoria = Categoria_Oficial.ID_Categoria
        WHERE Biblioteca.ID_Usuario = Usuario.ID_Usuario AND Categoria_Oficial.Nombre_Categoria = 'Estrategia' )
      AND EXISTS (
        SELECT 1 FROM Biblioteca  
        JOIN Juego_Categoria ON Biblioteca.ID_Producto = Juego_Categoria.ID_Producto
        JOIN Categoria_Oficial  ON Juego_Categoria.ID_Categoria = Categoria_Oficial.ID_Categoria
        WHERE Biblioteca.ID_Usuario = Usuario.ID_Usuario AND Categoria_Oficial.Nombre_Categoria = 'Terror' )
GROUP BY Usuario.ID_Usuario, Usuario.Nickname
HAVING SUM(Factura.Total_Pagado) > 100;

-- 8

SELECT  Generacion, 
        COUNT(*) AS Cantidad_Usuarios_Activos, 
        AVG(Gasto_Total) AS Gasto_Promedio
FROM ( SELECT  CASE
                    WHEN YEAR(Usuario.Fecha_Nacimiento) > 2000 THEN 'Gen Z'
                    WHEN YEAR(Usuario.Fecha_Nacimiento) BETWEEN 1981 AND 2000 THEN 'Millennials'
                    ELSE 'Gen X y anteriores'
               END AS Generacion,
               ISNULL(SUM(Factura.Total_Pagado),0) AS Gasto_Total
        FROM Usuario
        LEFT JOIN Factura ON Usuario.ID_Usuario = Factura.ID_Usuario
        WHERE Usuario.Estado_Cuenta = 'Activa'
        GROUP BY Usuario.ID_Usuario, Usuario.Fecha_Nacimiento) Generaciones 
GROUP BY Generacion;

-- 9

SELECT  Producto_Digital.Titulo AS Titulo,
        COUNT(Resena.ID_Resena) AS Total_Resenas,
        AVG(CAST(Resena.Calificacion_1_10 AS float)) AS  Promedio_Calificacion,
        CASE
            WHEN AVG(CAST(Resena.Calificacion_1_10 AS float)) < 4 THEN 'Crítico'
            WHEN AVG(CAST(Resena.Calificacion_1_10 AS float)) >= 4 AND AVG(CAST(Resena.Calificacion_1_10 AS float)) < 6 THEN 'Mixto'
            WHEN AVG(CAST(Resena.Calificacion_1_10 AS float)) >= 6 AND AVG(CAST(Resena.Calificacion_1_10 AS float)) < 7 THEN 'Divisivo'
        END AS Veredicto
FROM Producto_Digital
JOIN Juego_Base ON Producto_Digital.ID_Producto = Juego_Base.ID_Producto
JOIN Resena ON Producto_Digital.ID_Producto = Resena.ID_Producto
GROUP BY Producto_Digital.Titulo
HAVING COUNT(Resena.ID_Resena) >= 20 AND AVG(CAST(Resena.Calificacion_1_10 AS float)) < 7;

-- 10 

SELECT RJ.Titulo, 
       RJ.Estudio, 
       RJ.Total_Jugadores, 
       RJ.Promedio_Calificacion, 
       RJ.Puntaje_Reputacion
FROM ( SELECT JB.ID_Producto, 
       P.Titulo, 
       E.Nombre AS Estudio, 
       JB.ID_Estudio_Dev,
       (SELECT COUNT(DISTINCT ID_Usuario) FROM Biblioteca B WHERE B.ID_Producto = JB.ID_Producto) AS Total_Jugadores,
       COUNT(R.ID_Resena) AS Total_Resenas,
       AVG(CAST(R.Calificacion_1_10 AS FLOAT)) AS Promedio_Calificacion,
       dbo.fn_calcular_reputacion(JB.ID_Producto) AS Puntaje_Reputacion
       FROM Juego_Base JB
       JOIN Producto_Digital P ON JB.ID_Producto = P.ID_Producto
       JOIN Empresa_Corporativa E ON JB.ID_Estudio_Dev = E.ID_Empresa
       LEFT JOIN Resena R ON JB.ID_Producto = R.ID_Producto
       GROUP BY JB.ID_Producto, P.Titulo, E.Nombre, JB.ID_Estudio_Dev) RJ
JOIN ( SELECT JB.ID_Estudio_Dev, 
       AVG(CAST(R.Calificacion_1_10 AS FLOAT)) AS Promedio_Estudio
       FROM Juego_Base JB
       JOIN Resena R ON JB.ID_Producto = R.ID_Producto
       GROUP BY JB.ID_Estudio_Dev ) ME ON RJ.ID_Estudio_Dev = ME.ID_Estudio_Dev
CROSS JOIN ( SELECT AVG(dbo.fn_calcular_reputacion(ID_Producto)) AS Media_Reputacion_Global
             FROM Juego_Base ) RMP
WHERE RJ.Total_Resenas >= 20 AND RJ.Promedio_Calificacion > ME.Promedio_Estudio
      AND RJ.Puntaje_Reputacion > RMP.Media_Reputacion_Global
      AND NOT EXISTS ( SELECT 1 FROM Reembolso REM WHERE REM.ID_Producto = RJ.ID_Producto)
ORDER BY RJ.Puntaje_Reputacion DESC;

-- 11

SELECT  Usuario.Nickname,
        MAX(Biblioteca.Fecha_Ultima_Sesion) AS Fecha_Ultima_Sesion,
        SUM(Biblioteca.ID_Producto) AS Juegos_En_Biblioteca
FROM Usuario
JOIN Biblioteca ON Usuario.ID_Usuario = Biblioteca.ID_Usuario
WHERE NOT EXISTS ( SELECT 1 FROM Resena WHERE Resena.ID_Usuario = Usuario.ID_Usuario) AND
      NOT EXISTS ( SELECT 1 FROM Desbloqueo_Logro WHERE Desbloqueo_Logro.ID_Usuario = Usuario.ID_Usuario)
GROUP BY Usuario.ID_Usuario, Usuario.Nickname

-- 12 

SELECT TOP 3 ec.Nombre_Etiqueta, 
             SUM(pe.Cantidad_Votos) AS Votos_Totales, 
             COUNT(DISTINCT pe.ID_Producto) AS Productos_Asociados
FROM Etiqueta_Comunidad ec
JOIN Producto_Etiqueta pe ON ec.ID_Etiqueta = pe.ID_Etiqueta
JOIN Producto_Digital pd ON pe.ID_Producto = pd.ID_Producto
WHERE DATEDIFF(YEAR, pd.Fecha_Lanzamiento, GETDATE()) <= 1
GROUP BY ec.Nombre_Etiqueta 
ORDER BY SUM(pe.Cantidad_Votos) DESC;

-- 13 

SELECT  u.Nickname,
        pd.Titulo AS Titulo_Juego,
        COUNT(dl.ID_Logro) AS Total_Logros
FROM Usuario u
JOIN Desbloqueo_Logro dl ON u.ID_Usuario = dl.ID_Usuario
JOIN Producto_Digital pd ON dl.ID_Juego_Base = pd.ID_Producto
GROUP BY u.ID_Usuario, u.Nickname, pd.ID_Producto, pd.Titulo
HAVING  COUNT(dl.ID_Logro) = (  SELECT COUNT(*) 
                                FROM Logro l
                                WHERE l.ID_Juego_Base = pd.ID_Producto) 
        AND COUNT(DL.ID_Logro) > 0;

-- 14 

SELECT Estudio, 
       Pais_Origen, 
       Ingreso_Bruto, 
       Reembolsos, 
       Ingreso_Neto, 
       dbo.fn_clasificar_ingreso(Ingreso_Bruto) AS Tramo_Comision,
       Comision_Pct AS Comision,
       Monto_A_Pagar
FROM ( SELECT E.Nombre AS Estudio,
              E.Pais_Origen,
              ISNULL(Ventas.Bruto, 0) AS Ingreso_Bruto,
              ISNULL(Devoluciones.Monto, 0) AS Reembolsos,
              ISNULL(Ventas.Bruto, 0) - ISNULL(Devoluciones.Monto, 0) AS Ingreso_Neto,
              CASE dbo.fn_clasificar_ingreso(ISNULL(Ventas.Bruto, 0))
                  WHEN 'AAA' THEN 0.30
                  WHEN 'Consolidado' THEN 0.25
                  ELSE 0.20 
              END AS Comision_Pct,
              (ISNULL(Ventas.Bruto, 0) - ISNULL(Devoluciones.Monto, 0)) * 
              (1.0 - CASE dbo.fn_clasificar_ingreso(ISNULL(Ventas.Bruto, 0))
                        WHEN 'AAA' THEN 0.30
                        WHEN 'Consolidado' THEN 0.25
                        ELSE 0.20 
                     END ) AS Monto_A_Pagar
       FROM Empresa_Corporativa E
       LEFT JOIN (
            SELECT JB.ID_Estudio_Dev, 
            SUM(DF.Precio_Venta_Historico * (1 - DF.Descuento_Aplicado_Pct/100.0)) AS Bruto
            FROM Juego_Base JB
            JOIN Detalle_Factura DF ON JB.ID_Producto = DF.ID_Producto
            JOIN Factura F ON DF.ID_Factura = F.ID_Factura
            WHERE MONTH(F.Fecha_Hora_Emision) = MONTH(GETDATE()) AND YEAR(F.Fecha_Hora_Emision) = YEAR(GETDATE())
            GROUP BY JB.ID_Estudio_Dev ) Ventas ON E.ID_Empresa = Ventas.ID_Estudio_Dev
       LEFT JOIN (
            SELECT JB.ID_Estudio_Dev, SUM(R.Monto_Reembolsado) AS Monto
            FROM Juego_Base JB
            JOIN Reembolso R ON JB.ID_Producto = R.ID_Producto
            WHERE MONTH(R.Fecha_Reembolso) = MONTH(GETDATE()) AND YEAR(R.Fecha_Reembolso) = YEAR(GETDATE())
            GROUP BY JB.ID_Estudio_Dev ) Devoluciones ON E.ID_Empresa = Devoluciones.ID_Estudio_Dev
                   ) Pagos
WHERE Monto_A_Pagar > (
    SELECT AVG(Monto_A_Pagar) FROM (
        SELECT 
            (ISNULL(V.Bruto, 0) - ISNULL(D.Monto, 0)) * 
            (1.0 - CASE dbo.fn_clasificar_ingreso(ISNULL(V.Bruto, 0)) WHEN 'AAA' THEN 0.30 WHEN 'Consolidado' THEN 0.25 ELSE 0.20 END) AS Monto_A_Pagar
        FROM Empresa_Corporativa E2
        LEFT JOIN (SELECT JB.ID_Estudio_Dev, SUM(DF.Precio_Venta_Historico * (1 - DF.Descuento_Aplicado_Pct/100.0)) AS Bruto FROM Juego_Base JB JOIN Detalle_Factura DF ON JB.ID_Producto = DF.ID_Producto JOIN Factura F ON DF.ID_Factura = F.ID_Factura WHERE MONTH(F.Fecha_Hora_Emision) = MONTH(GETDATE()) AND YEAR(F.Fecha_Hora_Emision) = YEAR(GETDATE()) GROUP BY JB.ID_Estudio_Dev) V ON E2.ID_Empresa = V.ID_Estudio_Dev
        LEFT JOIN (SELECT JB.ID_Estudio_Dev, SUM(R.Monto_Reembolsado) AS Monto FROM Juego_Base JB JOIN Reembolso R ON JB.ID_Producto = R.ID_Producto WHERE MONTH(R.Fecha_Reembolso) = MONTH(GETDATE()) AND YEAR(R.Fecha_Reembolso) = YEAR(GETDATE()) GROUP BY JB.ID_Estudio_Dev) D ON E2.ID_Empresa = D.ID_Estudio_Dev
    ) PromediosTotales );

-- 15 

WITH SimsUsers AS (
    SELECT DISTINCT u.ID_Usuario, u.Nickname, pd.ID_Producto AS ID_Juego_Base
    FROM Usuario u
    JOIN Biblioteca b ON u.ID_Usuario = b.ID_Usuario
    JOIN Producto_Digital pd ON b.ID_Producto = pd.ID_Producto
    WHERE pd.Titulo = 'Los Sims 4'
),
DLC_Counts AS (
    SELECT su.ID_Usuario, COUNT(b.ID_Producto) AS Cantidad_DLC
    FROM SimsUsers su
    JOIN Biblioteca b ON su.ID_Usuario = b.ID_Usuario
    JOIN DLC d ON b.ID_Producto = d.ID_Producto
    WHERE d.ID_Juego_Base = su.ID_Juego_Base
    GROUP BY su.ID_Usuario
),
Mod_Counts AS (
    SELECT su.ID_Usuario, COUNT(sm.ID_Mod) AS Mods_Suscritos
    FROM SimsUsers su
    JOIN Suscripcion_Mod sm ON su.ID_Usuario = sm.ID_Usuario
    WHERE sm.ID_Producto_Base = su.ID_Juego_Base
    GROUP BY su.ID_Usuario
),
Money_Invested AS (
    SELECT su.ID_Usuario,
           (COALESCE(SUM(df.Precio_Venta_Historico * (1 - df.Descuento_Aplicado_Pct / 100.0)), 0) -
            COALESCE(SUM(r.Monto_Reembolsado), 0)) AS Dinero_Invertido
    FROM SimsUsers su
    JOIN Factura f ON su.ID_Usuario = f.ID_Usuario
    JOIN Detalle_Factura df ON f.ID_Factura = df.ID_Factura
    LEFT JOIN Reembolso r ON f.ID_Factura = r.ID_Factura AND r.ID_Producto = df.ID_Producto
    WHERE df.ID_Producto = su.ID_Juego_Base 
       OR df.ID_Producto IN (SELECT ID_Producto FROM DLC WHERE ID_Juego_Base = su.ID_Juego_Base)
    GROUP BY su.ID_Usuario
)
SELECT 
    su.Nickname,
    COALESCE(dc.Cantidad_DLC, dc.Cantidad_DLC, 0) AS Cantidad_DLC,
    COALESCE(mc.Mods_Suscritos, 0) AS Mods_Suscritos,
    COALESCE(mi.Dinero_Invertido, 0) AS Dinero_Invertido
FROM SimsUsers su
LEFT JOIN DLC_Counts dc ON su.ID_Usuario = dc.ID_Usuario
LEFT JOIN Mod_Counts mc ON su.ID_Usuario = mc.ID_Usuario
LEFT JOIN Money_Invested mi ON su.ID_Usuario = mi.ID_Usuario
WHERE COALESCE(dc.Cantidad_DLC, 0) >= 5
  AND COALESCE(mc.Mods_Suscritos, 0) >= 1
ORDER BY Dinero_Invertido DESC;

-- 16 

SELECT U.Nickname,
       B.Horas_Jugadas,
       (SELECT COUNT(*) 
        FROM Amistad_Usuario AU
        JOIN Usuario Amigo ON (AU.ID_Usuario_Receptor = Amigo.ID_Usuario OR AU.ID_Usuario_Solicitante = Amigo.ID_Usuario) AND Amigo.ID_Usuario <> U.ID_Usuario
        JOIN Biblioteca B_Amigo ON Amigo.ID_Usuario = B_Amigo.ID_Usuario
        WHERE (AU.ID_Usuario_Solicitante = U.ID_Usuario OR AU.ID_Usuario_Receptor = U.ID_Usuario)
               AND AU.Estado_Amistad = 'Aceptada'
               AND Amigo.Estado_Cuenta = 'Activa'
               AND B_Amigo.ID_Producto = P.ID_Producto) AS Amigos_Con_Juego
FROM Usuario U
JOIN Biblioteca B ON U.ID_Usuario = B.ID_Usuario
JOIN Producto_Digital P ON B.ID_Producto = P.ID_Producto
WHERE P.Titulo = 'Overcooked' AND (
      SELECT COUNT(*) 
      FROM Amistad_Usuario AU
      JOIN Usuario Amigo ON (AU.ID_Usuario_Receptor = Amigo.ID_Usuario OR AU.ID_Usuario_Solicitante = Amigo.ID_Usuario) AND Amigo.ID_Usuario <> U.ID_Usuario
      JOIN Biblioteca B_Amigo ON Amigo.ID_Usuario = B_Amigo.ID_Usuario
      WHERE (AU.ID_Usuario_Solicitante = U.ID_Usuario OR AU.ID_Usuario_Receptor = U.ID_Usuario)
            AND AU.Estado_Amistad = 'Aceptada'
            AND Amigo.Estado_Cuenta = 'Activa'
            AND B_Amigo.ID_Producto = P.ID_Producto) >= 2
ORDER BY Amigos_Con_Juego DESC;

-- 17 

SELECT pd.Titulo, pd.Precio_Base_Actual,
       (SELECT COUNT(*) FROM Soporte_Idioma si WHERE pd.ID_Producto = si.ID_Producto) AS Idiomas_Soportados,
       (SELECT COUNT(*) FROM Detalle_Factura df WHERE df.ID_Producto = pd.ID_Producto AND Descuento_Aplicado_Pct = 0) AS Ventas_Full_Price
FROM Juego_Base jb
JOIN Producto_Digital pd ON jb.ID_Producto = pd.ID_Producto
WHERE pd.Precio_Base_Actual > (SELECT AVG(pd2.Precio_Base_Actual) FROM Producto_Digital pd2 JOIN Juego_Base jb2 ON pd2.ID_Producto = jb2.ID_Producto)
      AND (SELECT COUNT(*) FROM Soporte_Idioma si WHERE pd.ID_Producto = si.ID_Producto) >= 4
      AND (SELECT COUNT(*) FROM Detalle_Factura df WHERE df.ID_Producto = pd.ID_Producto AND Descuento_Aplicado_Pct = 0) > 50;

-- 18 

WITH JerarquiaEmpresarial AS (
    SELECT ID_Empresa AS ID_Matriz_Principal,
           Nombre AS Empresa_Matriz_Principal,
           ID_Empresa AS ID_Subsidiaria,
           Nombre AS Empresa_Subsidiaria,
           0 AS Nivel_Jerarquia
    FROM Empresa_Corporativa
    WHERE ID_Empresa_Matriz IS NULL AND ID_Empresa IN (SELECT ID_Empresa_Matriz FROM Empresa_Corporativa)
    UNION ALL
    SELECT J.ID_Matriz_Principal,
           J.Empresa_Matriz_Principal,
           E.ID_Empresa,
           E.Nombre,
           J.Nivel_Jerarquia + 1
    FROM Empresa_Corporativa E
    JOIN JerarquiaEmpresarial J ON E.ID_Empresa_Matriz = J.ID_Subsidiaria )
SELECT J.Empresa_Matriz_Principal,
       J.Empresa_Subsidiaria,
       J.Nivel_Jerarquia,
       (SELECT COUNT(*) FROM Producto_Digital P JOIN Juego_Base JB ON P.ID_Producto = JB.ID_Producto WHERE JB.ID_Estudio_Dev = J.ID_Subsidiaria) 
       + (SELECT COUNT(*) FROM Producto_Digital P JOIN DLC ON P.ID_Producto = DLC.ID_Producto JOIN Juego_Base JB ON DLC.ID_Juego_Base = JB.ID_Producto WHERE JB.ID_Estudio_Dev = J.ID_Subsidiaria) AS Productos_Desarrollados,
       ISNULL((SELECT SUM(DF.Precio_Venta_Historico * (1 - DF.Descuento_Aplicado_Pct/100.0)) FROM Detalle_Factura DF JOIN Factura F ON DF.ID_Factura = F.ID_Factura JOIN Juego_Base JB ON DF.ID_Producto = JB.ID_Producto WHERE JB.ID_Estudio_Dev = J.ID_Subsidiaria AND MONTH(F.Fecha_Hora_Emision) = MONTH(GETDATE())), 0)
       - ISNULL((SELECT SUM(R.Monto_Reembolsado) FROM Reembolso R JOIN Juego_Base JB ON R.ID_Producto = JB.ID_Producto WHERE JB.ID_Estudio_Dev = J.ID_Subsidiaria AND MONTH(R.Fecha_Reembolso) = MONTH(GETDATE())), 0) AS Ingreso_Neto_Mensual
FROM JerarquiaEmpresarial J
WHERE J.Nivel_Jerarquia > 0;

-- 19

SELECT u.Nickname, pd.Titulo, r.Calificacion_1_10,
       (SELECT COUNT(*) FROM Desbloqueo_Logro dl WHERE dl.ID_Usuario = u.ID_Usuario AND dl.ID_Juego_Base = pd.ID_Producto) AS Cantidad_Logros_Desbloqueados,
       (SELECT COUNT(*) FROM Logro l WHERE l.ID_Juego_Base = pd.ID_Producto) AS Total_Logros
FROM Usuario u
JOIN Resena r ON u.ID_Usuario = r.ID_Usuario
JOIN Producto_Digital pd ON r.ID_Producto = pd.ID_Producto
JOIN Juego_Base jb ON pd.ID_Producto = jb.ID_producto
WHERE r.Calificacion_1_10 < 4 AND (SELECT COUNT(*) FROM Logro l WHERE l.ID_Juego_Base = pd.ID_Producto) > 0
      AND CAST((SELECT COUNT(*) FROM Desbloqueo_Logro dl WHERE dl.ID_Usuario = u.ID_Usuario AND dl.ID_Juego_Base = pd.ID_Producto) AS FLOAT) 
        / CAST((SELECT COUNT(*) FROM Logro l WHERE l.ID_Juego_Base = pd.ID_Producto) AS FLOAT) < 0.10;

-- 20 

DECLARE @ID_Usuario INT = 1; 

WITH RedAmigos AS (
    SELECT CASE 
            WHEN ID_Usuario_Solicitante = @ID_Usuario THEN ID_Usuario_Receptor
            ELSE ID_Usuario_Solicitante 
           END AS ID_Contacto,
           1 AS Grado_Separacion
    FROM Amistad_Usuario
    WHERE (ID_Usuario_Solicitante = @ID_Usuario OR ID_Usuario_Receptor = @ID_Usuario) AND Estado_Amistad = 'Aceptada'
    UNION ALL
    SELECT CASE 
            WHEN A.ID_Usuario_Solicitante = R.ID_Contacto THEN A.ID_Usuario_Receptor
            ELSE A.ID_Usuario_Solicitante 
           END,
           R.Grado_Separacion + 1
    FROM Amistad_Usuario A
    JOIN RedAmigos R ON (A.ID_Usuario_Solicitante = R.ID_Contacto OR A.ID_Usuario_Receptor = R.ID_Contacto)
    WHERE A.Estado_Amistad = 'Aceptada' AND R.Grado_Separacion < 3 AND A.ID_Usuario_Solicitante <> @ID_Usuario 
          AND A.ID_Usuario_Receptor <> @ID_Usuario),
ContactosFiltrados AS (
    SELECT ID_Contacto, 
           MIN(Grado_Separacion) AS Nivel_Minimo
    FROM RedAmigos
    GROUP BY ID_Contacto )
SELECT 
    U.Nickname AS Nickname_Contacto,
    CF.Nivel_Minimo AS Grado_Separacion,
    CASE CF.Nivel_Minimo
        WHEN 1 THEN 'Amigo directo'
        WHEN 2 THEN 'Amigo de un amigo'
        WHEN 3 THEN 'Contacto lejano'
    END AS Cercania,
    (SELECT COUNT(*) 
     FROM Biblioteca B_C 
     JOIN Juego_Base JB_C ON B_C.ID_Producto = JB_C.ID_Producto 
     WHERE B_C.ID_Usuario = CF.ID_Contacto 
       AND B_C.ID_Producto NOT IN (SELECT ID_Producto FROM Biblioteca WHERE ID_Usuario = @ID_Usuario)) AS Juegos_Recomendables
FROM ContactosFiltrados CF
JOIN Usuario U ON CF.ID_Contacto = U.ID_Usuario
WHERE (SELECT COUNT(*) 
       FROM Biblioteca B_C 
       JOIN Juego_Base JB_C ON B_C.ID_Producto = JB_C.ID_Producto 
       WHERE B_C.ID_Usuario = CF.ID_Contacto 
         AND B_C.ID_Producto NOT IN (SELECT ID_Producto FROM Biblioteca WHERE ID_Usuario = @ID_Usuario)) > 0
ORDER BY CF.Nivel_Minimo ASC, Juegos_Recomendables DESC;