-- =========================================
-- Financial Risk Analysis Project
-- Database Schema
-- =========================================

CREATE TABLE clientes (
    id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_email TEXT,
    cliente_nombre TEXT
);

CREATE TABLE proyectos (
    id_proyecto INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente INTEGER,
    proyecto_nombre TEXT,
    estado_proyecto TEXT,
    fecha_creacion_proyecto TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE facturas (
    id_factura INTEGER PRIMARY KEY AUTOINCREMENT,
    id_proyecto INTEGER,
    numero_factura TEXT,
    fecha_emision TEXT,
    fecha_vencimiento TEXT,
    importe_factura REAL,
    FOREIGN KEY (id_proyecto) REFERENCES proyectos(id_proyecto)
);

CREATE TABLE pagos (
    id_pago INTEGER PRIMARY KEY AUTOINCREMENT,
    id_factura INTEGER,
    fecha_pago TEXT,
    importe_pagado REAL,
    FOREIGN KEY (id_factura) REFERENCES facturas(id_factura)
);

CREATE TABLE  empresa_servicios_raw (
    cliente_nombre TEXT,
    cliente_email TEXT,
    proyecto_nombre TEXT,
    estado_proyecto TEXT,
    fecha_creacion_proyecto TEXT,
    numero_factura TEXT,
    fecha_emision TEXT,
    fecha_vencimiento TEXT,
    importe_factura REAL,
    fecha_pago TEXT,
    importe_pagado REAL
);