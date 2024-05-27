CREATE TABLE rakamin-kf-analytics-01.kimia_farma.tabel_analisa AS
SELECT
    t.transaction_id,
    t.date,
    b.branch_id,
    b.branch_name,
    b.kota,
    b.provinsi,
    b.rating_cabang,
    t.customer_name,
    p.product_id,
    p.product_name,
    p.price,
    t.discount_percentage,
    CASE
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS persentase_gross_laba,
    (p.price * (1 - t.discount_percentage / 100)) AS nett_sales,
    (p.price * (1 - t.discount_percentage / 100)) * 
    CASE
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS nett_profit,
    t.rating_transaksi
FROM
    rakamin-kf-analytics-01.kimia_farma.kf_final_transaction t
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_kantor_cabang b ON t.branch_id = b.branch_id
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_inventory c ON t.product_id = c.product_id
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_product p ON t.product_id = p.product_id
