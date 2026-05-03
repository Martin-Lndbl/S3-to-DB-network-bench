SELECT
    o_year,
    sum(
        CASE WHEN nation = 'BRAZIL' THEN
            volume
        ELSE
            0
        END) / sum(volume) AS mkt_share
FROM (
    SELECT
        extract(year FROM o_orderdate) AS o_year,
        l_extendedprice * (1 - l_discount) AS volume,
        n2.n_name AS nation
    FROM
        read_parquet('s3://duckdb-storage/part.parquet'),
        read_parquet('s3://duckdb-storage/supplier.parquet'),
        read_parquet('s3://duckdb-storage/lineitem.parquet'),
        read_parquet('s3://duckdb-storage/orders.parquet'),
        read_parquet('s3://duckdb-storage/customer.parquet'),
        read_parquet('s3://duckdb-storage/nation.parquet') as n1,
        read_parquet('s3://duckdb-storage/nation.parquet') as n2,
        read_parquet('s3://duckdb-storage/region.parquet')
    WHERE
        p_partkey = l_partkey
        AND s_suppkey = l_suppkey
        AND l_orderkey = o_orderkey
        AND o_custkey = c_custkey
        AND c_nationkey = n1.n_nationkey
        AND n1.n_regionkey = r_regionkey
        AND r_name = 'AMERICA'
        AND s_nationkey = n2.n_nationkey
        AND o_orderdate BETWEEN CAST('1995-01-01' AS date)
        AND CAST('1996-12-31' AS date)
        AND p_type = 'ECONOMY ANODIZED STEEL') AS all_nations
GROUP BY
    o_year
ORDER BY
    o_year;
