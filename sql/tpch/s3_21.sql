SELECT
    s_name,
    count(*) AS numwait
FROM
    read_parquet('s3://duckdb-storage/supplier.parquet'),
    read_parquet('s3://duckdb-storage/lineitem.parquet') as l1,
    read_parquet('s3://duckdb-storage/orders.parquet'),
    read_parquet('s3://duckdb-storage/nation.parquet')
WHERE
    s_suppkey = l1.l_suppkey
    AND o_orderkey = l1.l_orderkey
    AND o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT
            *
        FROM
            read_parquet('s3://duckdb-storage/lineitem.parquet') as l2
        WHERE
            l2.l_orderkey = l1.l_orderkey
            AND l2.l_suppkey <> l1.l_suppkey)
    AND NOT EXISTS (
        SELECT
            *
        FROM
            read_parquet('s3://duckdb-storage/lineitem.parquet') as l3
        WHERE
            l3.l_orderkey = l1.l_orderkey
            AND l3.l_suppkey <> l1.l_suppkey
            AND l3.l_receiptdate > l3.l_commitdate)
    AND s_nationkey = n_nationkey
    AND n_name = 'SAUDI ARABIA'
GROUP BY
    s_name
ORDER BY
    numwait DESC,
    s_name
LIMIT 100;
