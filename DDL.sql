-- Tablas

-- Empresa_Corporativa

CREATE TABLE Empresa_Corporativa (ID_Empresa integer IDENTITY(1,1) PRIMARY KEY, Nombre varchar(50), 
Pais_Origen varchar(50), Fecha_Fundacion date, ID_Empresa_Matriz integer,
FOREIGN KEY (ID_Empresa_Matriz) REFERENCES Empresa_Corporativa(ID_Empresa) );

-- Producto_Digital

CREATE TABLE Producto_Digital (ID_Producto integer IDENTITY(1,1) PRIMARY KEY, Titulo varchar(50), 
Descripcion_Corta varchar(100), Descripcion_Larga text, Fecha_Lanzamiento date, Tamano_GB decimal(10,2), 
Clasificacion_Edad varchar(50), Precio_Base_Actual decimal(10,2), Tipo_Producto varchar(50), Metacritic_Score integer,
CONSTRAINT CK_Precio_Base_Actual CHECK (Precio_Base_Actual >= 0),
CONSTRAINT CK_Tipo_Producto CHECK (Tipo_Producto IN ('Juego_Base', 'DLC')),
CONSTRAINT CK_Clasificacion_Edad CHECK (Clasificacion_Edad IN ('E', 'T', 'M', 'AO')),
CONSTRAINT CK_Metacritic_Score CHECK (Metacritic_Score BETWEEN 0 AND 100) );

-- Galeria_Multimedia

CREATE TABLE Galeria_Multimedia (ID_Producto integer, ID_Multimedia integer, URL_Archivo varchar(50), 
Tipo_Archivo varchar(50), 
PRIMARY KEY (ID_Producto, ID_Multimedia),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE, 
CONSTRAINT CK_Tipo_Archivo CHECK (Tipo_Archivo IN ('Foto', 'Video')) );

-- Juego_Base

CREATE TABLE Juego_Base (ID_Producto integer PRIMARY KEY FOREIGN KEY REFERENCES Producto_Digital(ID_Producto), 
ID_Estudio_Dev integer FOREIGN KEY REFERENCES Empresa_Corporativa (ID_Empresa),
ID_Publisher integer FOREIGN KEY REFERENCES Empresa_Corporativa (ID_Empresa),
Motor_Grafico varchar(50), Tiene_Compras_InGame bit, Soporta_Cloud_Saves bit );

-- DLC

CREATE TABLE DLC ( ID_Producto integer PRIMARY KEY FOREIGN KEY REFERENCES Producto_Digital(ID_Producto),
ID_Juego_Base integer FOREIGN KEY REFERENCES Juego_Base(ID_Producto) NOT NULL,
Tipo_Contenido varchar(50), Subtipo_Jugable varchar(50),
CONSTRAINT CK_Tipo_Contenido CHECK (Tipo_Contenido IN ('Jugable', 'Banda_Sonora', 'Arte')),
CONSTRAINT CK_Subtipo_Jugable CHECK 
	( (Tipo_Contenido = 'Jugable' AND Subtipo_Jugable IN ('Personaje', 'Mapa', 'Modo_Juego', 'Cosmetico'))
	OR
	(Tipo_Contenido = 'Jugable' AND Subtipo_Jugable IS NULL) )
);

-- Perfil_Requisito 

CREATE TABLE Perfil_Requisito (ID_Producto integer, Tipo_Perfil varchar(50), Sistema_Operativo varchar(50),
Procesador varchar(50), Memoria_RAM varchar(50), Tarjeta_Grafica varchar(50),
PRIMARY KEY (ID_Producto, Tipo_Perfil),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE,
CONSTRAINT CK_Tipo_Perfil CHECK (Tipo_Perfil IN ('Minimo', 'Recomendado')) );

-- Logro 

CREATE TABLE Logro (ID_Juego_Base integer, ID_Logro integer, Nombre_Logro varchar(50), Descripcion_Logro varchar(50), 
Es_Secreto bit,
PRIMARY KEY (ID_Juego_Base, ID_Logro),
FOREIGN KEY (ID_Juego_Base) REFERENCES Juego_Base (ID_Producto) ON DELETE CASCADE);

-- Categoria_Oficial

CREATE TABLE Categoria_Oficial (ID_Categoria integer PRIMARY KEY, Nombre_Categoria varchar(50), 
Descripcion_Categoria varchar(100) );

-- Juego_Categoria

CREATE TABLE Juego_Categoria (ID_Producto integer, ID_Categoria integer,
PRIMARY KEY (ID_Producto , ID_Categoria),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Categoria) REFERENCES Categoria_Oficial(ID_Categoria));

-- Idioma 

CREATE TABLE Idioma (ID_Idioma integer PRIMARY KEY, Nombre_Idioma varchar(50));

-- Soporte_Idioma

CREATE TABLE Soporte_Idioma (ID_Producto integer, ID_Idioma integer, Soporta_Interfaz bit, Soporta_Audio bit,
Soporta_Subtitulos bit, 
PRIMARY KEY(ID_Producto, ID_Idioma),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Idioma) REFERENCES Idioma(ID_Idioma));

-- Etiqueta_Comunidad

CREATE TABLE Etiqueta_Comunidad (ID_Etiqueta integer PRIMARY KEY, Nombre_Etiqueta varchar(50));

-- Producto_Etiqueta 

CREATE TABLE Producto_Etiqueta (ID_Producto integer, ID_Etiqueta integer, Cantidad_Votos integer,
PRIMARY KEY(ID_Producto,ID_Etiqueta),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Etiqueta) REFERENCES Etiqueta_Comunidad(ID_Etiqueta) );

-- Mod

CREATE TABLE Mod (ID_Producto_Base integer, ID_Mod integer, Nombre_Mod varchar(50), Descripcion_Mod varchar(50), 
Tamano_MB decimal(10,2),
PRIMARY KEY (ID_Producto_Base, ID_Mod),
FOREIGN KEY (ID_Producto_Base) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE);

-- Usuario 

CREATE TABLE Usuario (ID_Usuario integer IDENTITY(1,1) PRIMARY KEY, Nickname varchar(50), Correo varchar(50), 
Contrasena_Hash varchar(50), Fecha_Nacimiento date, Fecha_Registro date, Pais_Residencia varchar(50), 
Estado_Cuenta varchar(50),
CONSTRAINT CK_Fecha_Nacimiento CHECK (DATEDIFF(YEAR, Fecha_Nacimiento, GETDATE()) >= 13),
CONSTRAINT CK_Estado_Cuenta CHECK (Estado_Cuenta IN ('Activa', 'Suspendida', 'Baneada')) );

-- Amistad_Usuario

CREATE TABLE Amistad_Usuario (ID_Usuario_Solicitante integer, ID_Usuario_Receptor integer, Fecha_Amistad date,
Estado_Amistad varchar(50), PRIMARY KEY(ID_Usuario_Solicitante, ID_Usuario_Receptor),
FOREIGN KEY (ID_Usuario_Solicitante) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Usuario_Receptor) REFERENCES Usuario(ID_Usuario), 
CONSTRAINT CK_Estado_Amistad CHECK (Estado_Amistad IN ('Pendiente', 'Aceptada', 'Bloqueada')) );

-- Desbloqueo_Logro 
 
CREATE TABLE Desbloqueo_Logro (ID_Usuario integer, ID_Juego_Base integer, ID_Logro integer, Fecha_Desbloqueo date,
PRIMARY KEY (ID_Usuario, ID_Juego_Base, ID_Logro),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Juego_Base) REFERENCES Juego_Base (ID_Producto),
FOREIGN KEY (ID_Juego_Base, ID_Logro) REFERENCES Logro(ID_Juego_Base, ID_Logro) );

-- Biblioteca

CREATE TABLE Biblioteca (ID_Usuario integer, ID_Producto integer, Horas_Jugadas decimal, Fecha_Ultima_Sesion date,
PRIMARY KEY (ID_Usuario, ID_Producto),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) );

-- Lista_Deseos

CREATE TABLE Lista_Deseos (ID_Usuario integer, ID_Producto integer, Fecha_Agregado date, Notificar_Descuento bit,
PRIMARY KEY (ID_Usuario, ID_Producto),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ); 

-- Carrito

CREATE TABLE Carrito (ID_Usuario integer, ID_Producto integer, Fecha_Agregado date,
PRIMARY KEY (ID_Usuario, ID_Producto),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) );

-- Resena

CREATE TABLE Resena (ID_Resena integer IDENTITY (1,1) PRIMARY KEY, ID_Usuario integer, ID_Producto integer, 
Texto_Resena varchar(100), Calificacion_1_10 integer, Fecha_Publicacion date, Es_Critica_Especializada bit,
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
CONSTRAINT CK_Calificacion_1_10 CHECK (Calificacion_1_10 BETWEEN 1 AND 10) ); 

-- Suscripcion_Mod

CREATE TABLE Suscripcion_Mod (ID_Usuario integer, ID_Producto_Base integer, ID_Mod integer, Fecha_Suscripcion date,
PRIMARY KEY (ID_Usuario, ID_Producto_Base, ID_Mod),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto_Base) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Producto_Base, ID_Mod) REFERENCES Mod(ID_Producto_Base, ID_Mod) ); 
 
-- Metodo_Pago

CREATE TABLE Metodo_Pago (ID_Metodo_Pago integer PRIMARY KEY, Nombre_Metodo varchar(50), Moneda varchar(50),
Requiere_Validacion bit); 

-- Factura

CREATE TABLE Factura(ID_Factura	integer IDENTITY(1,1) PRIMARY KEY, Codigo_Transaccion varchar(50), Fecha_Hora_Emision date,
Sub_Total decimal(10,2), Monto_Descuento decimal(10,2), Monto_Impuesto decimal(10,2), Total_Pagado decimal(10,2),
ID_Usuario integer, ID_Metodo_Pago integer, 
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Metodo_Pago) REFERENCES Metodo_Pago(ID_Metodo_Pago),
CONSTRAINT CK_Sub_Total CHECK (Sub_Total >= 0),
CONSTRAINT CK_Monto_Descuento CHECK (Monto_Descuento >= 0),
CONSTRAINT CK_Monto_Impuesto CHECK (Monto_Impuesto >= 0),
CONSTRAINT CK_Total_Pagado CHECK (Total_Pagado >= 0) );

-- Detalle_Factura

CREATE TABLE Detalle_Factura (ID_Factura integer, ID_Producto integer, Precio_Venta_Historico decimal(10,2),
Descuento_Aplicado_Pct decimal(10,2), 
PRIMARY KEY(ID_Factura, ID_Producto),
FOREIGN KEY (ID_Factura) REFERENCES Factura (ID_Factura),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
CONSTRAINT CK_Precio_Venta_Historico CHECK (Precio_Venta_Historico >= 0),
CONSTRAINT CK_Descuento_Aplicado_Pct CHECK (Descuento_Aplicado_Pct >= 0) );

-- Reembolso 

CREATE TABLE Reembolso (ID_Reembolso integer IDENTITY(1,1) PRIMARY KEY, ID_Factura integer, ID_Producto integer,
Fecha_Reembolso date, Monto_Reembolsado decimal(10,2), Motivo varchar(50),
FOREIGN KEY (ID_Factura) REFERENCES Factura (ID_Factura),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
CONSTRAINT CK_Monto_Reembolsado CHECK (Monto_Reembolsado >= 0) );

-- Historial_Descuento

CREATE TABLE Historial_Descuento (ID_Producto integer, Fecha_Inicio date, Fecha_Fin date, 
Porcentaje_Descuento decimal(10,2), Nombre_Evento varchar(50), 
PRIMARY KEY (ID_Producto, Fecha_Inicio), 
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE,
CONSTRAINT CK_Porcentaje_Descuento CHECK (Porcentaje_Descuento BETWEEN 0 AND 100),
CONSTRAINT CK_Coherencia_Fechas CHECK (Fecha_Fin >= Fecha_Inicio) ); 

-- Registro_Concurrencia 

CREATE TABLE Registro_Concurrencia(ID_Producto integer, Fecha_Registro date, Pico_Maximo_Jugadores integer,
PRIMARY KEY (ID_Producto, Fecha_Registro),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE);