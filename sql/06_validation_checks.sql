-- =========================================
-- Financial Risk Analysis Project
-- Validation Checks
-- =========================================
-- Objective:
-- Validate that the analytical dataset is consistent
-- and that financial metrics reconcile with the
-- original transactional tables.
--
-- Checks included:
-- - Invoice count validation
-- - Revenue reconciliation
-- - Outstanding balance validation
-- - Duplicate detection
-- =========================================

-- =========================================
-- Check 1: Invoice count validation
-- =========================================

SELECT
    (SELECT COUNT(*) FROM facturas) AS total_facturas_tabla,
    (SELECT COUNT(*) FROM v_dataset_financiero) AS total_facturas_dataset;

-- =========================================
-- Check 2: Revenue reconciliation
-- =========================================

SELECT
    (SELECT SUM(importe_factura) FROM facturas) AS facturacion_tabla,
    (SELECT SUM(importe_factura) FROM v_dataset_financiero) AS facturacion_dataset;

-- =========================================
-- Check 3: Outstanding balance validation
-- =========================================

SELECT
    SUM(importe_factura) AS facturacion_total,
    SUM(total_pagado) AS cobros_totales,
    SUM(saldo_pendiente) AS saldo_pendiente_total
FROM v_dataset_financiero;

