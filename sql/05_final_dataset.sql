-- =========================================
-- Financial Risk Analysis Project
-- Final Analytical Dataset
-- =========================================
-- Objective:
-- Build the final dataset at invoice level,
-- combining financial, payment and aging metrics
-- in a single analytical layer ready for BI tools.
--
-- Dataset included:
-- - Client
-- - Project
-- - Invoice details
-- - Payment metrics
-- - Outstanding balance
-- - Aging classification
-- =========================================

DROP VIEW IF EXISTS v_dataset_financiero;

CREATE VIEW v_dataset_financiero AS
WITH pagos_por_factura AS (
    SELECT
        f.id_factura,
        f.numero_factura,
        f.id_proyecto,
        f.fecha_emision,
        f.fecha_vencimiento,
        f.importe_factura,
        COALESCE(SUM(p.importe_pagado), 0) AS total_pagado,
        (f.importe_factura - COALESCE(SUM(p.importe_pagado), 0)) AS saldo_pendiente
    FROM facturas f
    LEFT JOIN pagos p
        ON p.id_factura = f.id_factura
    GROUP BY
        f.id_factura,
        f.numero_factura,
        f.id_proyecto,
        f.fecha_emision,
        f.fecha_vencimiento,
        f.importe_factura
)

SELECT
    c.cliente_nombre AS cliente,
    pr.proyecto_nombre AS proyecto,
    ppf.numero_factura,
    ppf.fecha_emision,
    ppf.fecha_vencimiento,
    ppf.importe_factura,
    ppf.total_pagado,
    ppf.saldo_pendiente,
    CASE
        WHEN ppf.fecha_vencimiento < date('now')
        THEN CAST(julianday(date('now')) - julianday(ppf.fecha_vencimiento) AS INTEGER)
        ELSE 0
    END AS dias_vencida,
    CASE
        WHEN ppf.fecha_vencimiento >= date('now') THEN 'No vencida'
        WHEN julianday(date('now')) - julianday(ppf.fecha_vencimiento) <= 30 THEN '0-30'
        WHEN julianday(date('now')) - julianday(ppf.fecha_vencimiento) <= 60 THEN '31-60'
        WHEN julianday(date('now')) - julianday(ppf.fecha_vencimiento) <= 90 THEN '61-90'
        ELSE '90+'
    END AS tramo_aging
FROM pagos_por_factura ppf
JOIN proyectos pr
    ON pr.id_proyecto = ppf.id_proyecto
JOIN clientes c
    ON c.id_cliente = pr.id_cliente;