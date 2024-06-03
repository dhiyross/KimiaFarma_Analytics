CREATE TABLE kimia_farma.kf_analisa_transaksi AS
SELECT
    FT.transaction_id,         -- Kode ID transaksi
    FT.date,                   -- Tanggal transaksi dilakukan
    KC.branch_id,              -- Kode ID cabang Kimia Farma
    KC.branch_name,            -- Nama cabang Kimia Farma
    KC.kota,                   -- Kota cabang Kimia Farma
    KC.provinsi,               -- Provinsi cabang Kimia Farma
    KC.rating AS rating_cabang,-- Penilaian konsumen terhadap cabang Kimia Farma
    FT.customer_name,          -- Nama customer yang melakukan transaksi
    P.product_id,              -- Kode produk obat
    P.product_name,            -- Nama obat
    FT.price,                  -- Harga obat
    FT.discount_percentage,    -- Persentase diskon yang diberikan pada obat
    -- Persentase laba berdasarkan harga obat
    CASE
        WHEN FT.price <= 50000 THEN 0.1
        WHEN FT.price > 50000 AND FT.price <= 100000 THEN 0.15
        WHEN FT.price > 100000 AND FT.price <= 300000 THEN 0.2
        WHEN FT.price > 300000 AND FT.price <= 500000 THEN 0.25
        WHEN FT.price > 500000 THEN 0.30
        ELSE 0.3
    END AS persentase_gross_laba,
    -- Harga setelah diskon
    FT.price * (1 - FT.discount_percentage) AS nett_sales,
    -- Keuntungan bersih berdasarkan harga setelah diskon dan persentase laba
    (FT.price * (1 - FT.discount_percentage) * 
        CASE
            WHEN FT.price <= 50000 THEN 0.1
            WHEN FT.price > 50000 AND FT.price <= 100000 THEN 0.15
            WHEN FT.price > 100000 AND FT.price <= 300000 THEN 0.2
            WHEN FT.price > 300000 AND FT.price <= 500000 THEN 0.25
            WHEN FT.price > 500000 THEN 0.30
            ELSE 0.3
        END) AS nett_profit,
    FT.rating AS rating_transaksi -- Penilaian konsumen terhadap transaksi yang dilakukan
FROM 
  `kimia_farma.kf_final_transaction` AS FT  -- Tabel transaksi akhir
LEFT JOIN 
  `kimia_farma.kf_kantor_cabang` AS KC ON FT.branch_id = KC.branch_id -- Gabungan dengan tabel cabang berdasarkan branch_id
LEFT JOIN 
  `kimia_farma.kf_product` AS P ON FT.product_id = P.product_id -- Gabungan dengan tabel produk berdasarkan product_id
;

-- Create Aggregate Table 1: Pendapatan Pertahun --
CREATE TABLE kimia_farma.kf_year_income AS
SELECT
    EXTRACT(YEAR FROM TA.date) AS tahun,
    SUM(nett_sales) AS income,
    AVG(nett_sales) AS avg_income
FROM
    `kimia_farma.kf_analisa_transaksi` AS TA
GROUP BY
    tahun
ORDER BY
    tahun
;

-- Create Aggregate Table 2: Total Transaksi Provinsi --
CREATE TABLE kimia_farma.kf_total_transaksi_provinsi AS
SELECT 
    provinsi, 
    COUNT(*) AS total_transaction,
    SUM(nett_sales) AS total_income
FROM 
    `kimia_farma.kf_analisa_transaksi` AS TA
GROUP BY 
    provinsi
ORDER BY 
    total_transaction DESC
LIMIT 10
;

-- Create Aggregate Table 3: Nett Sales Provinsi --
CREATE TABLE kimia_farma.kf_nett_sales_provinsi AS 
SELECT 
    provinsi, 
    SUM(nett_sales) AS nett_sales_cabang,
    COUNT(TA.product_id) AS total_product_sold
FROM 
    `kimia_farma.kf_analisa_transaksi` AS TA
GROUP BY 
    provinsi
ORDER BY 
    nett_sales_cabang DESC
LIMIT 10
;

-- Create Aggregate Table 4: Cabang Rating Tertinggi, Rating Transaksi Rendah --
CREATE TABLE kimia_farma.kf_rating_cabang_tinggi_transaksi_rendah AS
SELECT
    KC.branch_name,
    KC.kota, 
    AVG(FT.rating) AS avg_rating_transaksi, 
    KC.rating AS rating_cabang
FROM 
    `kimia_farma.kf_final_transaction` AS FT
LEFT JOIN 
    `kimia_farma.kf_kantor_cabang` AS KC
ON 
    FT.branch_id = KC.branch_id
GROUP BY 
    KC.branch_name, KC.kota, KC.rating
ORDER BY 
    KC.rating DESC, AVG(FT.rating) ASC
LIMIT 5
;

-- Create Aggregate Table 5: Total Profit Provinsi --
CREATE TABLE kimia_farma.kf_total_profit_provinsi AS
SELECT
    provinsi,
    SUM(nett_profit) AS total_profit,
    COUNT(product_id) AS total_product_sold
FROM 
    `kimia_farma.kf_analisa_transaksi` AS TA
GROUP BY 
    provinsi
ORDER BY
    total_profit DESC, total_product_sold DESC
;

-- Create Aggregate Table 6: Jumlah Transaksi Customer --
CREATE TABLE kimia_farma.kf_total_customer_transaction AS
SELECT
    customer_name,
    COUNT(transaction_id) AS total_transaction
FROM 
    `kimia_farma.kf_analisa_transaksi` AS TA
WHERE 
    EXTRACT(YEAR FROM date) BETWEEN 2020 AND 2023
GROUP BY 
    customer_name
ORDER BY 
    total_transaction DESC
LIMIT 5
;
