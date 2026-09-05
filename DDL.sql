-- Tablas

-- Empresa_Corporativa

CREATE TABLE Empresa_Corporativa (ID_Empresa integer PRIMARY KEY, Nombre text, Pais_Origen text, Fecha_Fundacion date,
ID_Empresa_Matriz integer, FOREIGN KEY (ID_Empresa_Matriz) REFERENCES Empresa_Corporativa(ID_Empresa) );

-- Producto_Digital

CREATE TABLE Producto_Digital (ID_Producto integer PRIMARY KEY, Titulo text, Descripcion_Corta text, 
Descripcion_Larga text, Fecha_Lanzamiento date, Tamano_GB decimal, Clasificacion_Edad text , Precio_Base_Actual decimal
, Tipo_Producto text, Metacritic_Score integer);

-- Galeria_Multimedia

CREATE TABLE Galeria_Multimedia (ID_Producto integer, ID_Multimedia integer, URL_Archivo text, Tipo_Archivo text, 
PRIMARY KEY (ID_Producto, ID_Multimedia),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE);

-- Juego_Base

CREATE TABLE Juego_Base (ID_Producto integer PRIMARY KEY FOREIGN KEY REFERENCES Producto_Digital(ID_Producto), 
ID_Estudio_Dev integer FOREIGN KEY REFERENCES Empresa_Corporativa (ID_Empresa),
ID_Publisher integer FOREIGN KEY REFERENCES Empresa_Corporativa (ID_Empresa),
Motor_Grafico text, Tiene_Compras_InGame bit, Soporta_Cloud_Saves bit );

-- DLC

CREATE TABLE DLC ( ID_Producto integer PRIMARY KEY FOREIGN KEY REFERENCES Producto_Digital(ID_Producto),
ID_Juego_Base integer FOREIGN KEY REFERENCES Juego_Base(ID_Producto),
Tipo_Contenido text, Subtipo_Jugable text);

-- Perfil_Requisito 

CREATE TABLE Perfil_Requisito (ID_Producto integer, Tipo_Perfil varchar(50), Sistema_Operativo text, Procesador text,
Memoria_RAM text, Tarjeta_Grafica text,
PRIMARY KEY (ID_Producto, Tipo_Perfil),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE );

-- Logro 

CREATE TABLE Logro (ID_Juego_Base integer, ID_Logro integer, Nombre_Logro text, Descripcion_Logro text, 
Es_Secreto bit,
PRIMARY KEY (ID_Juego_Base, ID_Logro),
FOREIGN KEY (ID_Juego_Base) REFERENCES Juego_Base (ID_Producto) ON DELETE CASCADE);

-- Categoria_Oficial

CREATE TABLE Categoria_Oficial (ID_Categoria integer PRIMARY KEY, Nombre_Categoria text, Descripcion_Categoria text);

-- Juego_Categoria

CREATE TABLE Juego_Categoria (ID_Producto integer, ID_Categoria integer,
PRIMARY KEY (ID_Producto , ID_Categoria),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Categoria) REFERENCES Categoria_Oficial(ID_Categoria));

-- Idioma 

CREATE TABLE Idioma (ID_Idioma integer PRIMARY KEY, Nombre_Idioma text);

-- Soporte_Idioma

CREATE TABLE Soporte_Idioma (ID_Producto integer, ID_Idioma integer, Soporta_Interfaz bit, Soporta_Audio bit,
Soporta_Subtitulos bit, PRIMARY KEY(ID_Producto, ID_Idioma),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Idioma) REFERENCES Idioma(ID_Idioma));

-- Etiqueta_Comunidad

CREATE TABLE Etiqueta_Comunidad (ID_Etiqueta integer PRIMARY KEY, Nombre_Etiqueta text);

-- Producto_Etiqueta 

CREATE TABLE Producto_Etiqueta (ID_Producto integer, ID_Etiqueta integer, Cantidad_Votos integer,
PRIMARY KEY(ID_Producto,ID_Etiqueta),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Etiqueta) REFERENCES Etiqueta_Comunidad(ID_Etiqueta) );

-- Mod

CREATE TABLE Mod (ID_Producto_Base integer, ID_Mod integer, Nombre_Mod text, Descripcion_Mod text, Tamano_MB decimal,
PRIMARY KEY (ID_Producto_Base, ID_Mod),
FOREIGN KEY (ID_Producto_Base) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE);

-- Usuario 

CREATE TABLE Usuario (ID_Usuario integer PRIMARY KEY, Nickname text, Correo text, Contrasena_Hash text,
Fecha_Nacimiento date, Fecha_Registro date, Pais_Residencia text, Estado_Cuenta text);

-- Amistad_Usuario

CREATE TABLE Amistad_Usuario (ID_Usuario_Solicitante integer, ID_Usuario_Receptor integer, Fecha_Amistad date,
Estado_Amistad text, PRIMARY KEY(ID_Usuario_Solicitante, ID_Usuario_Receptor),
FOREIGN KEY (ID_Usuario_Solicitante) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Usuario_Receptor) REFERENCES Usuario(ID_Usuario));

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

CREATE TABLE Lista_Deseos (ID_Usuario integer, ID_Producto integer, Fecha_Agregado date, Notificar_Descuento text,
PRIMARY KEY (ID_Usuario, ID_Producto),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ); 

-- Carrito

CREATE TABLE Carrito (ID_Usuario integer, ID_Producto integer, Fecha_Agregado date,
PRIMARY KEY (ID_Usuario, ID_Producto),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) );

-- Resena

CREATE TABLE Resena (ID_Resena integer PRIMARY KEY, ID_Usuario integer, ID_Producto integer, Texto_Resena text,
Calificacion_1_10 integer, Fecha_Publicacion date, Es_Critica_Especializada bit,
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ); 

-- Suscripcion_Mod

CREATE TABLE Suscripcion_Mod (ID_Usuario integer, ID_Producto_Base integer, ID_Mod integer, Fecha_Suscripcion date,
PRIMARY KEY (ID_Usuario, ID_Producto_Base, ID_Mod),
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Producto_Base) REFERENCES Producto_Digital(ID_Producto),
FOREIGN KEY (ID_Producto_Base, ID_Mod) REFERENCES Mod(ID_Producto_Base, ID_Mod) ); 
 
-- Metodo_Pago

CREATE TABLE Metodo_Pago (ID_Metodo_Pago integer PRIMARY KEY, Nombre_Metodo text, Moneda text, Requiere_Validacion bit); 

-- Factura

CREATE TABLE Factura(ID_Factura	integer PRIMARY KEY, Codigo_Transaccion integer, Fecha_Hora_Emision date,
Sub_Total decimal, Monto_Descuento decimal, Monto_Impuesto decimal, Total_Pagado decimal, ID_Usuario integer,
ID_Metodo_Pago integer, 
FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario),
FOREIGN KEY (ID_Metodo_Pago) REFERENCES Metodo_Pago(ID_Metodo_Pago) );

-- Detalle_Factura

CREATE TABLE Detalle_Factura (ID_Factura integer, ID_Producto integer, Precio_Venta_Historico decimal,
Descuento_Aplicado_Pct decimal, 
PRIMARY KEY(ID_Factura, ID_Producto),
FOREIGN KEY (ID_Factura) REFERENCES Factura (ID_Factura),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) );

-- Reembolso 

CREATE TABLE Reembolso (ID_Reembolso integer PRIMARY KEY, ID_Factura integer, ID_Producto integer, Fecha_Reembolso date,
Monto_Reembolsado decimal, Motivo text,
FOREIGN KEY (ID_Factura) REFERENCES Factura (ID_Factura),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) );

-- Historial_Descuento

CREATE TABLE Historial_Descuento (ID_Producto integer, Fecha_Inicio date, Fecha_Fin date, Porcentaje_Descuento decimal,
Nombre_Evento text, 
PRIMARY KEY (ID_Producto, Fecha_Inicio), 
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE); 

-- Registro_Concurrencia 

CREATE TABLE Registro_Concurrencia(ID_Producto integer, Fecha_Registro date, Pico_Maximo_Jugadores integer,
PRIMARY KEY (ID_Producto, Fecha_Registro),
FOREIGN KEY (ID_Producto) REFERENCES Producto_Digital(ID_Producto) ON DELETE CASCADE);