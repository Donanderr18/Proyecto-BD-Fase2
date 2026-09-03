-- Tablas

-- Empresa_Corporativa

CREATE TABLE Empresa_Corporativa (id_empresa integer PRIMARY KEY, nombre text, pais_origen text, fecha_fundacion date,
id_empresa_matriz integer, FOREIGN KEY (id_empresa_matriz) REFERENCES Empresa_Corporativa(id_empresa) );
