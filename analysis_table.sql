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
