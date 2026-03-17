-- =========================================
-- Financial Risk Analysis Project
-- Financial KPIs
-- =========================================
-- Objective:
-- Build executive financial indicators to assess
-- debt risk, client concentration and revenue trends.
--
-- KPIs included:
-- - Overdue debt ratio
-- - Client debt concentration
-- - Monthly revenue
-- =========================================


-- =========================================
-- KPI 1: Overdue debt ratio
-- =========================================

DROP VIEW IF EXISTS v_ratio_deuda_vencida;

CREATE VIEW v_ratio_deuda_vencida AS
SELECT
    SUM(CASE
        WHEN dias_vencida > 0 THEN saldo_pendiente
        ELSE 0
    END) AS deuda_vencida,
    SUM(saldo_pendiente) AS deuda_total,
    ROUND(
        100.0 * SUM(CASE
            WHEN dias_vencida > 0 THEN saldo_pendiente
            ELSE 0
        END) / NULLIF(SUM(saldo_pendiente), 0),
        2
    ) AS pct_deuda_vencida
FROM v_facturas_pendientes;

-- =========================================
-- KPI 2: Client debt concentration
-- =========================================

DROP VIEW IF EXISTS v_concentracion_deuda_clientes;

CREATE VIEW v_concentracion_deuda_clientes AS 
SELECT
    cliente,
    SUM(saldo_pendiente) AS deuda_cliente,
    ROUND(
        100.0 * SUM(saldo_pendiente) /
        NULLIF((SELECT SUM(saldo_pendiente) FROM v_facturas_pendientes), 0),
        2
    ) AS pct_deuda_total
FROM v_facturas_pendientes
GROUP BY cliente
ORDER BY deuda_cliente DESC;

-- =========================================
-- KPI 3: Monthly revenue
-- =========================================

DROP VIEW IF EXISTS v_facturacion_mensual;

CREATE VIEW v_facturacion_mensual AS
SELECT
    strftime('%Y-%m', fecha_emision) AS mes,
    COUNT(*) AS num_facturas,
    SUM(importe_factura) AS facturacion_total
FROM facturas
GROUP BY strftime('%Y-%m', fecha_emision)
ORDER BY mes;
