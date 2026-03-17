-- =========================================
-- Financial Risk Analysis Project
-- Exploratory Data Analysis
-- =========================================
-- Objective:
-- Explore the raw dataset and validate data quality
-- before building the analytical model.
--
-- Checks performed:
-- - Row counts
-- - Client duplicates
-- - Invoice validation
-- - Payment consistency
-- =========================================


-- =========================================
-- Check 1: Row count in raw dataset
-- =========================================

SELECT COUNT(*) AS total_rows
FROM empresa_servicios_raw;

-- =========================================
-- Check 2: Detect duplicated clients by email
-- =========================================

SELECT
    cliente_email,
    COUNT(*) AS num_registros
FROM empresa_servicios_raw
GROUP BY cliente_email
HAVING COUNT(*) > 1
ORDER BY num_registros DESC;

-- =========================================
-- Check 3: Detect duplicated invoices
-- =========================================

SELECT
    numero_factura,
    COUNT(*) AS num_registros
FROM empresa_servicios_raw
GROUP BY numero_factura
HAVING COUNT(*) > 1
ORDER BY num_registros DESC;

-- =========================================
-- Check 4: Number of payments per invoice
-- =========================================

SELECT
    numero_factura,
    COUNT(fecha_pago) AS num_pagos
FROM empresa_servicios_raw
GROUP BY numero_factura
ORDER BY num_pagos DESC;

-- =========================================
-- Check 5: Invoices without payment
-- =========================================

SELECT
    numero_factura,
    cliente_nombre,
    importe_factura
FROM empresa_servicios_raw
WHERE fecha_pago IS NULL
ORDER BY importe_factura DESC;

-- =========================================
-- Check 6: Payments without invoice reference
-- =========================================

SELECT
    numero_factura,
    fecha_pago,
    importe_pagado
FROM empresa_servicios_raw
WHERE numero_factura IS NULL;
