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