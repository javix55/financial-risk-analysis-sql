-- =========================================
-- Financial Risk Analysis Project
-- Analytical Views
-- =========================================
-- Objective:
-- Build reusable analytical views to support
-- dashboards and financial reporting.
--
-- Views included:
-- - Pending invoices
-- - Executive KPIs
-- - Client debt ranking
-- - Project debt ranking
-- - Global aging
-- - DSO calculation
-- =========================================

-- =========================================
-- View 1: Pending invoices detail
-- =========================================

DROP VIEW IF EXISTS v_facturas_pendientes;

CREATE VIEW v_facturas_pendientes AS 
SELECT
    c.cliente_nombre AS cliente,
    pr.proyecto_nombre AS proyecto,
    f.numero_factura,
    f.id_factura,
    f.fecha_emision,
    f.fecha_vencimiento,
    f.importe_factura,
    COALESCE(SUM(pg.importe_pagado), 0) AS total_pagado,
    (f.importe_factura - COALESCE(SUM(pg.importe_pagado), 0)) AS saldo_pendiente,
    CASE
        WHEN f.fecha_vencimiento < date('now')
        THEN CAST(julianday(date('now')) - julianday(f.fecha_vencimiento) AS INTEGER)
        ELSE 0
    END AS dias_vencida
FROM facturas f
LEFT JOIN pagos pg
    ON pg.id_factura = f.id_factura
JOIN proyectos pr
    ON f.id_proyecto = pr.id_proyecto
JOIN clientes c
    ON pr.id_cliente = c.id_cliente
GROUP BY 
    c.cliente_nombre,
    pr.proyecto_nombre,
    f.numero_factura,
    f.id_factura,
    f.fecha_emision,
    f.fecha_vencimiento,
    f.importe_factura
HAVING (f.importe_factura - COALESCE(SUM(pg.importe_pagado), 0)) > 0
ORDER BY
    dias_vencida DESC,
    saldo_pendiente DESC;

-- =========================================
-- View 2: Executive KPIs summary
-- =========================================

DROP VIEW IF EXISTS v_kpis_resumen;

CREATE VIEW v_kpis_resumen AS 
WITH pagos_por_factura AS (
    SELECT
        f.id_factura,
        f.importe_factura,
        f.fecha_emision,
        f.fecha_vencimiento,
        COALESCE(SUM(p.importe_pagado), 0) AS total_pagado,
        (f.importe_factura - COALESCE(SUM(p.importe_pagado), 0)) AS saldo_pendiente
    FROM facturas f
    LEFT JOIN pagos p
        ON p.id_factura = f.id_factura
    GROUP BY
        f.id_factura,
        f.importe_factura,
        f.fecha_emision,
        f.fecha_vencimiento
)

SELECT
    COUNT(*) AS num_facturas_total,
    SUM(importe_factura) AS facturacion_total,
    SUM(total_pagado) AS cobrado_total,
    SUM(saldo_pendiente) AS pendiente_total,
    SUM(CASE WHEN saldo_pendiente > 0 THEN 1 ELSE 0 END) AS facturas_pendientes,
    SUM(CASE WHEN saldo_pendiente > 0 AND fecha_vencimiento < date('now') THEN 1 ELSE 0 END) AS facturas_vencidas,
    ROUND(
        100.0 * SUM(total_pagado) / NULLIF(SUM(importe_factura), 0),
        2
    ) AS pct_cobro
FROM pagos_por_factura;

-- =========================================
-- View 3: Client debt ranking
-- =========================================

DROP VIEW IF EXISTS v_ranking_clientes_pendientes;

CREATE VIEW v_ranking_clientes_pendientes AS
WITH pagos_por_factura AS (
    SELECT
        f.id_factura,
        f.id_proyecto,
        f.importe_factura,
        f.fecha_vencimiento,
        COALESCE(SUM(p.importe_pagado), 0) AS total_pagado,
        (f.importe_factura - COALESCE(SUM(p.importe_pagado), 0)) AS saldo_pendiente
    FROM facturas f
    LEFT JOIN pagos p
        ON p.id_factura = f.id_factura
    GROUP BY
        f.id_factura,
        f.id_proyecto,
        f.importe_factura,
        f.fecha_vencimiento
)

SELECT
    c.cliente_nombre AS cliente,
    COUNT(*) AS num_facturas,
    SUM(ppf.saldo_pendiente) AS pendiente_total,
    SUM(CASE
        WHEN ppf.saldo_pendiente > 0 AND ppf.fecha_vencimiento < date('now')
        THEN 1
        ELSE 0
    END) AS facturas_vencidas
FROM pagos_por_factura ppf
JOIN proyectos pr
    ON pr.id_proyecto = ppf.id_proyecto
JOIN clientes c
    ON c.id_cliente = pr.id_cliente
WHERE ppf.saldo_pendiente > 0
GROUP BY c.cliente_nombre
ORDER BY pendiente_total DESC;

-- =========================================
-- View 4: Project debt ranking
-- =========================================

DROP VIEW IF EXISTS v_ranking_proyectos_pendiente;

CREATE VIEW v_ranking_proyectos_pendiente AS
WITH pagos_por_factura AS (
    SELECT
        f.id_factura,
        f.id_proyecto,
        f.fecha_vencimiento,
        f.importe_factura,
        COALESCE(SUM(p.importe_pagado), 0) AS total_pagado,
        (f.importe_factura - COALESCE(SUM(p.importe_pagado), 0)) AS saldo_pendiente
    FROM facturas f
    LEFT JOIN pagos p
        ON p.id_factura = f.id_factura
    GROUP BY
        f.id_factura,
        f.id_proyecto,
        f.fecha_vencimiento,
        f.importe_factura
)

SELECT
    c.cliente_nombre AS cliente,
    pr.proyecto_nombre AS proyecto,
    COUNT(*) AS num_facturas,
    SUM(ppf.saldo_pendiente) AS pendiente_total,
    SUM(CASE
        WHEN ppf.saldo_pendiente > 0 AND ppf.fecha_vencimiento < date('now')
        THEN 1
        ELSE 0
    END) AS facturas_vencidas,
    MAX(CASE
        WHEN ppf.fecha_vencimiento < date('now')
        THEN CAST(julianday(date('now')) - julianday(ppf.fecha_vencimiento) AS INTEGER)
        ELSE 0
    END) AS max_dias_vencida
FROM pagos_por_factura ppf
JOIN proyectos pr
    ON pr.id_proyecto = ppf.id_proyecto
JOIN clientes c
    ON c.id_cliente = pr.id_cliente
WHERE ppf.saldo_pendiente > 0
GROUP BY
    c.cliente_nombre,
    pr.proyecto_nombre
ORDER BY pendiente_total DESC;

-- =========================================
-- View 5: Global aging
-- =========================================

DROP VIEW IF EXISTS v_aging_global;

CREATE VIEW v_aging_global AS
WITH pendientes AS (
    SELECT
        f.id_factura,
        f.fecha_vencimiento,
        (f.importe_factura - COALESCE(SUM(p.importe_pagado), 0)) AS saldo_pendiente,
        CASE
            WHEN f.fecha_vencimiento < date('now')
            THEN CAST (julianday(date('now')) - julianday(f.fecha_vencimiento) AS INTEGER)
            ELSE 0
            END AS dias_vencida
        FROM facturas f
        LEFT JOIN pagos p
            ON p.id_factura = f.id_factura
        GROUP BY
            f.id_factura,
            f.fecha_vencimiento,
            f.importe_factura
        HAVING saldo_pendiente > 0
)

SELECT
    CASE
        WHEN dias_vencida BETWEEN 0 AND 30 THEN '0-30'
        WHEN dias_vencida BETWEEN 31 AND 60 THEN '31-60'
        WHEN dias_vencida BETWEEN 61 AND 90 THEN '61-90'
        ELSE '90+'
    END AS tramo aging,
    COUNT(*) AS num_facturas,
    SUM(saldo_pendiente) AS total_pendiente,
    MAX(dias_vencida) AS max_dias_vencida
FROM pendientes
GROUP BY tramo_aging
ORDER BY
    CASE tramo_aging
        WHEN '0-30' THEN 1
        WHEN '31-60' THEN 2
        WHEN '61-90' THEN 3
        ELSE 4
    END;
    
-- =========================================
-- View 6: Days Sales Outstanding (DSO)
-- =========================================

DROP VIEW IF EXISTS v_dso_cobro;

CREATE VIEW v_dso_cobro AS
SELECT
    AVG(
        julianday(p.fecha_pago) - julianday(f.fecha_emuision)
    ) dias_promedio_cobro
FROM pagos p
JOIN facturas f
    ON p.id_factura = f.id_factura;