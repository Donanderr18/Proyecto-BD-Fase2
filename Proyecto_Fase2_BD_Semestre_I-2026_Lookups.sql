-- Lookups.sql  —  Material suministrado por la materia

-- Categoria_Oficial

INSERT INTO Categoria_Oficial (ID_Categoria, Nombre_Categoria, Descripcion_Categoria) VALUES
	(1 , 'Acción',        'Juegos centrados en combate, reflejos y desafíos físicos.'),
	(2 , 'Aventura',      'Exploración, narrativa y resolución de acertijos.'),
	(3 , 'RPG',           'Juegos de rol con progresión de personaje e historia.'),
	(4 , 'Estrategia',    'Toma de decisiones, gestión de recursos y táctica.'),
	(5 , 'Terror',        'Ambientación de horror y supervivencia.'),
	(6 , 'Deportes',      'Simulación de disciplinas deportivas.'),
	(7 , 'Carreras',      'Competencias de velocidad y conducción.'),
	(8 , 'Simulación',    'Recreación de sistemas o actividades reales.'),
	(9 , 'Indie',         'Producciones de estudios independientes.'),
	(10, 'Mundo Abierto', 'Mundos explorables sin progresión lineal.'),
	(11, 'Un Jugador',    'Experiencia individual (single-player).'),
	(12, 'Multijugador',  'Partidas en línea o local con varios jugadores.'),
	(13, 'Puzzle',        'Resolución de rompecabezas y lógica.'),
	(14, 'Plataformas',   'Saltos y desplazamiento por niveles.'),
	(15, 'Shooter',       'Disparos en primera o tercera persona.'),
	(16, 'Cooperativo',   'Juego colaborativo entre varios jugadores.'),
	(17, 'Rol',			  'Encarnan a un personaje ficticio para construir una historia en conjunto.'),
	(18, 'Magia',		  'Involucran ilusiones con pañuelos, huevos, sal, monedas, y más.'),
	(19, 'Educativo',     'Combinan la diversión con el aprendizaje.'),
	(20, 'Musica',		  'Integran la música de manera fundamental en su jugabilidad.');

-- Idioma

INSERT INTO Idioma (ID_Idioma, Nombre_Idioma) VALUES
	(1 , 'Español'),
	(2 , 'Inglés'),
	(3 , 'Francés'),
	(4 , 'Alemán'),
	(5 , 'Portugués'),
	(6 , 'Italiano'),
	(7 , 'Japonés'),
	(8 , 'Coreano'),
	(9 , 'Chino (Mandarín)'),
	(10, 'Ruso');

-- Metodo_Pago

INSERT INTO Metodo_Pago (ID_Metodo_Pago, Nombre_Metodo, Moneda, Requiere_Validacion) VALUES
	 (1, 'Tarjeta de Crédito',   'USD', 1),
	 (2, 'Tarjeta de Débito',    'USD', 1),
	 (3, 'PayPal',               'USD', 1),
	 (4, 'Zelle',                'USD', 1),
	 (5, 'Pago Móvil',           'VES', 1),
	 (6, 'Criptomoneda (USDT)',  'USD', 1),
	 (7, 'Saldo ConeSTeam',      'USD', 0);
