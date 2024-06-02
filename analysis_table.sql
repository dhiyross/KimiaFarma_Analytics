CREATE TABLE rakamin-kf-analytics-01.kimia_farma.tabel_analisa AS
SELECT
    FT.transaction_id,
    FT.date,
    KC.branch_id,
    KC.branch_name,
    KC.kota,
    KC.provinsi,
    KC.rating AS rating_cabang,
    FT.customer_name,
    P.product_id,
    P.product_name,
    P.price,
    FT.discount_percentage,
    CASE
        WHEN P.price <= 50000 THEN 0.10
        WHEN P.price > 50000 AND P.price <= 100000 THEN 0.15
        WHEN P.price > 100000 AND P.price <= 300000 THEN 0.20
        WHEN P.price > 300000 AND P.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS persentase_gross_laba,
    (P.price * (1 - FT.discount_percentage)) AS nett_sales,
    (P.price * (1 - FT.discount_percentage)) * 
    CASE
        WHEN P.price <= 50000 THEN 0.10
        WHEN P.price > 50000 AND P.price <= 100000 THEN 0.15
        WHEN P.price > 100000 AND P.price <= 300000 THEN 0.20
        WHEN P.price > 300000 AND P.price <= 500000 THEN 0.25
        ELSE 0.30
    END AS nett_profit,
    FT.rating AS rating_transaksi
FROM
    rakamin-kf-analytics-01.kimia_farma.kf_final_transaction FT
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_kantor_cabang KC ON FT.branch_id = KC.branch_id
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_inventory I ON FT.product_id = I.product_id
JOIN
    rakamin-kf-analytics-01.kimia_farma.kf_product P ON FT.product_id = P.product_id
