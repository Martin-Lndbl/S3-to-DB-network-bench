SELECT
    o_orderpriority,
    count(*) AS order_count
FROM
    read_parquet('/scratch/ilya/tpch300/orders.parquet')
WHERE
    o_orderdate >= CAST('1993-07-01' AS date)
    AND o_orderdate < CAST('1993-10-01' AS date)
    AND EXISTS (
        SELECT
            *
        FROM
            read_parquet('/scratch/ilya/tpch300/lineitem.parquet')
        WHERE
            l_orderkey = o_orderkey
            AND l_commitdate < l_receiptdate)
GROUP BY
    o_orderpriority
ORDER BY
    o_orderpriority;
