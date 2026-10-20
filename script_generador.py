import random
from datetime import datetime, timedelta
from faker import Faker

fake = Faker('es_ES')

# --- CONFIGURACIÓN Y CONSTANTES ---
FILE_NAME = "Inserts.sql"
TOTAL_EMPRESAS = 45
TOTAL_PRODUCTOS = 300
TOTAL_USUARIOS = 260
TOTAL_FACTURAS = 550

# Listas basadas en Lookups.sql suministrado por la materia
CATEGORIAS = list(range(1, 21)) # ID del 1 al 20
IDIOMAS = list(range(1, 11)) # ID del 1 al 10
METODOS_PAGO = list(range(1, 8)) # ID del 1 al 7

# --- GENERADORES DE DATOS COHERENTES ---
prefijos_empresa = ['Pixel', 'Quantum', 'Iron', 'Nova', 'Epic', 'Cosmic', 'Red', 'Blue', 'Poly', 'NextGen']
sufijos_empresa = ['Studios', 'Games', 'Interactive', 'Entertainment', 'Arts', 'Software', 'Forge', 'Works']

prefijos_juego = ['The Legend of', 'Call to', 'Age of', 'World of', 'Super', 'Pro', 'Cyber', 'Dark', 'Liga de']
sustantivos_juego = ['Warriors', 'Empires', 'Soccer', 'Plumber Bros', 'Crafter', 'Souls', 'Galaxy', 'Strike', 'Fútbol', 'Tierra']
adjetivos_juego = ['Infinito', 'Épico', 'Letal', 'Místico', 'Supremo', '2026', 'Deluxe', 'Ultimate']

descripciones_cortas = [
    "Adéntrate en una aventura inolvidable llena de desafíos.",
    "Gestiona tu propio equipo y llévalo a la gloria mundial.",
    "Construye, excava y sobrevive en este mundo generado proceduralmente.",
    "Salta, corre y esquiva obstáculos para rescatar el reino.",
    "Enfrenta a jugadores de todo el mundo en batallas tácticas.",
    "Explora un vasto universo lleno de misterios y peligros."
]

descripciones_largas = [
    "Un título que redefine el género con gráficos de última generación, mecánicas profundas de personalización y un modo campaña que te atrapará por decenas de horas. Descubre secretos ocultos y domina todas las habilidades disponibles para convertirte en el mejor.",
    "Disfruta de la simulación más realista creada hasta la fecha. Con físicas mejoradas, un motor gráfico renovado y cientos de opciones de gestión, cada decisión que tomes impactará en tu progreso y en el entorno que te rodea.",
    "Reúne a tus amigos y adéntrate en este multijugador cooperativo donde la coordinación es la clave. Lucha contra hordas de enemigos, recolecta recursos valiosos y mejora tu equipamiento base para sobrevivir a las noches más oscuras."
]

nombres_dlc = ['Expansion Pack: Tierras Olvidadas', 'Cosméticos de Temporada', 'Nuevas Leyendas y Jugadores', 'Paquete de Mapas Extra', 'Modo Supervivencia Extrema']
desc_dlc = "Expande tu experiencia con nuevo contenido oficial que añade horas de diversión, nuevas mecánicas y desafíos inéditos para los jugadores más experimentados."

def generar_nombre_empresa():
    return f"{random.choice(prefijos_empresa)} {random.choice(sufijos_empresa)}"

def generar_titulo_juego():
    if random.random() > 0.5:
        return f"{random.choice(prefijos_juego)} {random.choice(sustantivos_juego)}"
    else:
        return f"{random.choice(sustantivos_juego)} {random.choice(adjetivos_juego)}"

def escape_sql(text):
    if text is None: return "NULL"
    return "'" + str(text).replace("'", "''") + "'"

# --- INICIO DE LA ESCRITURA DEL ARCHIVO ---
with open(FILE_NAME, "w", encoding="utf-8") as f:
    f.write("-- ==========================================\n")
    f.write("-- Proyecto Fase 2: Data Seeding Generado (Coherente)\n")
    f.write("-- ==========================================\n\n")

    # 1. EMPRESAS CORPORATIVAS
    f.write("-- 1. Empresa_Corporativa\n")
    empresas = []
    for i in range(1, TOTAL_EMPRESAS + 1):
        nombre = generar_nombre_empresa()
        pais = fake.country()
        fecha_fund = fake.date_between(start_date='-30y', end_date='-5y')
        
        id_matriz = "NULL"
        if i > 30: 
            id_matriz = random.randint(1, 10)
            
        f.write(f"INSERT INTO Empresa_Corporativa (Nombre, Pais_Origen, Fecha_Fundacion, ID_Empresa_Matriz) VALUES ({escape_sql(nombre)}, {escape_sql(pais)}, '{fecha_fund}', {id_matriz});\n")
        empresas.append(i)

    # 2. PRODUCTOS DIGITALES
    f.write("\n-- 2. Producto_Digital, Juego_Base y DLC\n")
    juegos_base = []
    dlcs = []
    
    juegos_especiales = [
        {'titulo': 'Los Sims 4', 'tipo': 'Juego_Base', 'precio': 39.99, 'clasif': 'T', 'desc_c': 'Simulador de vida y construcción.', 'desc_l': 'Crea y controla personas en un mundo virtual sin reglas. Expresa tu creatividad personalizando la apariencia y personalidad de tus Sims.'},
        {'titulo': 'Overcooked', 'tipo': 'Juego_Base', 'precio': 19.99, 'clasif': 'E', 'desc_c': 'Juego de cocina cooperativo y caótico.', 'desc_l': 'Trabaja en equipo (o contra él) para preparar y servir una variedad de pedidos antes de que los clientes enfurezcan.'},
        {'titulo': 'Terraria', 'tipo': 'Juego_Base', 'precio': 9.99, 'clasif': 'T', 'desc_c': 'Aventura de acción y sandbox en 2D.', 'desc_l': 'Excava, lucha, explora y construye. El mundo entero es tu lienzo en esta aventura llena de acción y recolección de materiales.'},
        {'titulo': 'FIFA 19', 'tipo': 'Juego_Base', 'precio': 59.99, 'clasif': 'E', 'desc_c': 'Simulador de fútbol profesional.', 'desc_l': 'Vive la emoción del deporte rey con gráficos realistas, el modo carrera definitivo y licencias oficiales de las mejores ligas del mundo.'},
        {'titulo': 'Juego Elite Cero Reembolsos', 'tipo': 'Juego_Base', 'precio': 49.99, 'clasif': 'M', 'desc_c': 'Obra maestra aclamada por la crítica.', 'desc_l': 'Un RPG de mundo abierto impecable que ha logrado mantener un nivel de satisfacción del 100% en toda su comunidad de jugadores.'},
        {'titulo': 'Juego Polemico Malas Resenas', 'tipo': 'Juego_Base', 'precio': 29.99, 'clasif': 'M', 'desc_c': 'Lanzamiento desastroso lleno de bugs.', 'desc_l': 'Una promesa incumplida de la industria que salió al mercado con múltiples problemas de rendimiento y mecánicas rotas.'}
    ]

    producto_id_counter = 1
    
    for juego in juegos_especiales:
        f.write(f"INSERT INTO Producto_Digital (Titulo, Descripcion_Corta, Descripcion_Larga, Fecha_Lanzamiento, Tamano_GB, Clasificacion_Edad, Precio_Base_Actual, Tipo_Producto, Metacritic_Score) VALUES ({escape_sql(juego['titulo'])}, {escape_sql(juego['desc_c'])}, {escape_sql(juego['desc_l'])}, '{fake.date_between(start_date='-5y', end_date='-1y')}', {round(random.uniform(5.0, 50.0), 2)}, '{juego['clasif']}', {juego['precio']}, 'Juego_Base', {random.randint(60, 95)});\n")
        id_dev = random.choice(empresas)
        id_pub = id_dev if random.choice([True, False]) else random.choice(empresas)
        f.write(f"INSERT INTO Juego_Base (ID_Producto, ID_Estudio_Dev, ID_Publisher, Motor_Grafico, Tiene_Compras_InGame, Soporta_Cloud_Saves) VALUES ({producto_id_counter}, {id_dev}, {id_pub}, 'Unreal Engine 5', 1, 1);\n")
        juegos_base.append(producto_id_counter)
        producto_id_counter += 1

    for i in range(len(juegos_especiales) + 1, TOTAL_PRODUCTOS + 1):
        is_dlc = random.random() < 0.30
        tipo_prod = 'DLC' if is_dlc else 'Juego_Base'
        clasif = random.choice(['E', 'T', 'M', 'AO'])
        precio = 0 if (is_dlc and random.random() < 0.25) else round(random.uniform(5.0, 69.99), 2)
        score = random.randint(40, 98)
        
        if is_dlc:
            titulo = random.choice(nombres_dlc)
            desc_c = "Paquete de expansión de contenido."
            desc_l = desc_dlc
        else:
            titulo = generar_titulo_juego()
            desc_c = random.choice(descripciones_cortas)
            desc_l = random.choice(descripciones_largas)
        
        f.write(f"INSERT INTO Producto_Digital (Titulo, Descripcion_Corta, Descripcion_Larga, Fecha_Lanzamiento, Tamano_GB, Clasificacion_Edad, Precio_Base_Actual, Tipo_Producto, Metacritic_Score) VALUES ({escape_sql(titulo)}, {escape_sql(desc_c)}, {escape_sql(desc_l)}, '{fake.date_between(start_date='-4y', end_date='today')}', {round(random.uniform(1.0, 100.0), 2)}, '{clasif}', {precio}, '{tipo_prod}', {score});\n")
        
        if not is_dlc:
            id_dev = random.choice(empresas)
            f.write(f"INSERT INTO Juego_Base (ID_Producto, ID_Estudio_Dev, ID_Publisher, Motor_Grafico, Tiene_Compras_InGame, Soporta_Cloud_Saves) VALUES ({producto_id_counter}, {id_dev}, {id_dev}, 'Unity', {random.choice([0,1])}, 1);\n")
            juegos_base.append(producto_id_counter)
        else:
            juego_padre = random.choice(juegos_base) if juegos_base else 1
            f.write(f"INSERT INTO DLC (ID_Producto, ID_Juego_Base, Tipo_Contenido, Subtipo_Jugable) VALUES ({producto_id_counter}, {juego_padre}, 'Jugable', 'Modo_Juego');\n")
            dlcs.append(producto_id_counter)
            
        producto_id_counter += 1

    # DLCs obligatorios para el reporte de Los Sims 4
    for i in range(5):
        f.write(f"INSERT INTO Producto_Digital (Titulo, Descripcion_Corta, Descripcion_Larga, Fecha_Lanzamiento, Tamano_GB, Clasificacion_Edad, Precio_Base_Actual, Tipo_Producto, Metacritic_Score) VALUES ('Sims 4 Expansion Pack {i+1}', 'Expansión que añade nuevas profesiones y mundos.', 'Mejora la vida de tus Sims con muebles exclusivos, interacciones sociales ampliadas y mecánicas de estilo de vida.', '2025-01-01', 5.0, 'T', 19.99, 'DLC', 80);\n")
        f.write(f"INSERT INTO DLC (ID_Producto, ID_Juego_Base, Tipo_Contenido, Subtipo_Jugable) VALUES ({producto_id_counter}, 1, 'Jugable', 'Cosmetico');\n")
        producto_id_counter += 1

    # 3. MODS Y LOGROS
    f.write("\n-- 3. Logros y Mods\n")
    for j_id in juegos_base:
        num_logros = random.randint(5, 10)
        for log_id in range(1, num_logros + 1):
            f.write(f"INSERT INTO Logro (ID_Juego_Base, ID_Logro, Nombre_Logro, Descripcion_Logro, Es_Secreto) VALUES ({j_id}, {log_id}, 'Logro Desafío {log_id}', 'Alcanza el objetivo especial de este nivel.', {random.choice([0,1])});\n")
            
    f.write("INSERT INTO Mod (ID_Producto_Base, ID_Mod, Nombre_Mod, Descripcion_Mod, Tamano_MB) VALUES (1, 1, 'Mascotas Extendidas Mod', 'Añade una mascota gata negra y otras razas raras al juego base.', 15.5);\n")

    # 4. USUARIOS
    f.write("\n-- 4. Usuarios\n")
    dominios = ["@gmail.com", "@hotmail.com", "@ucv.ve", "@yahoo.com"]
    usuarios = []
    
    for i in range(1, TOTAL_USUARIOS + 1):
        nick = fake.user_name() + str(i)
        correo = f"{nick}{random.choice(dominios)}"
        fecha_nac = fake.date_of_birth(minimum_age=14, maximum_age=50) 
        fecha_reg = fake.date_time_between(start_date='-2y', end_date='now')
        estado = random.choices(['Activa', 'Suspendida', 'Baneada'], weights=[90, 5, 5])[0]
        f.write(f"INSERT INTO Usuario (Nickname, Correo, Contrasena_Hash, Fecha_Nacimiento, Fecha_Registro, Pais_Residencia, Estado_Cuenta) VALUES ({escape_sql(nick)}, '{correo}', 'hash_seguro_123', '{fecha_nac}', '{fecha_reg}', '{fake.country()}', '{estado}');\n")
        usuarios.append(i)

    # 5. RED DE AMISTADES
    f.write("\n-- 5. Amistad_Usuario\n")
    for _ in range(300):
        u1, u2 = random.sample(usuarios, 2)
        estado = random.choice(['Pendiente', 'Aceptada', 'Bloqueada'])
        f.write(f"BEGIN TRY INSERT INTO Amistad_Usuario (ID_Usuario_Solicitante, ID_Usuario_Receptor, Fecha_Amistad, Estado_Amistad) VALUES ({u1}, {u2}, GETDATE(), '{estado}'); END TRY BEGIN CATCH END CATCH;\n")

    f.write("BEGIN TRY INSERT INTO Amistad_Usuario (ID_Usuario_Solicitante, ID_Usuario_Receptor, Fecha_Amistad, Estado_Amistad) VALUES (1, 2, GETDATE(), 'Aceptada'); END TRY BEGIN CATCH END CATCH;\n")
    f.write("BEGIN TRY INSERT INTO Amistad_Usuario (ID_Usuario_Solicitante, ID_Usuario_Receptor, Fecha_Amistad, Estado_Amistad) VALUES (1, 3, GETDATE(), 'Aceptada'); END TRY BEGIN CATCH END CATCH;\n")

    # 6. FACTURAS Y COMERCIO
    f.write("\n-- 6. Facturación y Detalles\n")
    factura_id = 1
    
    # Compras de prueba
    f.write(f"INSERT INTO Factura (Codigo_Transaccion, Fecha_Hora_Emision, Sub_Total, Monto_Descuento, Monto_Impuesto, Total_Pagado, ID_Usuario, ID_Metodo_Pago) VALUES ('TRX-SIMS-ESPECIAL', GETDATE(), 100, 0, 16, 116, 10, {random.choice(METODOS_PAGO)});\n")
    f.write(f"INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Precio_Venta_Historico, Descuento_Aplicado_Pct) VALUES ({factura_id}, 1, 39.99, 0);\n")
    for p_id in range(producto_id_counter - 5, producto_id_counter):
        f.write(f"INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Precio_Venta_Historico, Descuento_Aplicado_Pct) VALUES ({factura_id}, {p_id}, 19.99, 0);\n")
    f.write(f"INSERT INTO Suscripcion_Mod (ID_Usuario, ID_Producto_Base, ID_Mod, Fecha_Suscripcion) VALUES (10, 1, 1, GETDATE());\n")
    factura_id += 1

    for u_id in [1, 2, 3]:
        f.write(f"INSERT INTO Factura (Codigo_Transaccion, Fecha_Hora_Emision, Sub_Total, Monto_Descuento, Monto_Impuesto, Total_Pagado, ID_Usuario, ID_Metodo_Pago) VALUES ('TRX-OVC-{u_id}', GETDATE(), 19.99, 0, 3.19, 23.18, {u_id}, {random.choice(METODOS_PAGO)});\n")
        f.write(f"INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Precio_Venta_Historico, Descuento_Aplicado_Pct) VALUES ({factura_id}, 2, 19.99, 0);\n")
        factura_id += 1

    for _ in range(TOTAL_FACTURAS):
        u_id = random.choice(usuarios)
        f.write(f"INSERT INTO Factura (Codigo_Transaccion, Fecha_Hora_Emision, Sub_Total, Monto_Descuento, Monto_Impuesto, Total_Pagado, ID_Usuario, ID_Metodo_Pago) VALUES ('TRX-{fake.uuid4()[:8]}', '{fake.date_time_between(start_date='-2y', end_date='now')}', 50, 0, 8, 58, {u_id}, {random.choice(METODOS_PAGO)});\n")
        for _ in range(random.randint(1, 3)):
            p_id = random.choice(juegos_base)
            f.write(f"BEGIN TRY INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Precio_Venta_Historico, Descuento_Aplicado_Pct) VALUES ({factura_id}, {p_id}, 29.99, 0); END TRY BEGIN CATCH END CATCH;\n")
        factura_id += 1

    # 7. RESEÑAS Y REEMBOLSOS
    f.write("\n-- 7. Reseñas y Reembolsos\n")
    resenas = [
        "El juego superó mis expectativas, los gráficos son geniales.",
        "Tiene potencial, pero los controles se sienten un poco toscos.",
        "Una historia cautivadora y mecánicas sólidas, recomendado.",
        "Demasiados bugs en el lanzamiento, esperen a un parche.",
        "El diseño de sonido es magistral, muy inmersivo."
    ]
    for _ in range(800):
        u_id = random.choice(usuarios)
        p_id = random.choice(juegos_base)
        calif = random.randint(1, 10)
        critica = random.choice([0, 1]) if calif > 7 else 0
        texto = escape_sql(random.choice(resenas))
        f.write(f"BEGIN TRY INSERT INTO Resena (ID_Usuario, ID_Producto, Texto_Resena, Calificacion_1_10, Fecha_Publicacion, Es_Critica_Especializada) VALUES ({u_id}, {p_id}, {texto}, {calif}, GETDATE(), {critica}); END TRY BEGIN CATCH END CATCH;\n")

    for i in range(35):
        f.write(f"INSERT INTO Reembolso (ID_Factura, ID_Producto, Fecha_Reembolso, Monto_Reembolsado, Motivo) VALUES ({random.randint(10, 500)}, {random.choice(juegos_base)}, GETDATE(), 19.99, 'Rendimiento deficiente en mi sistema');\n")

    print("Archivo Inserts.sql generado exitosamente.")