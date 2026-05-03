SELECT
    c_name,
    c_custkey,
    o_orderkey,
    o_orderdate,
    o_totalprice,
    sum(l_quantity)
FROM
    read_parquet('/scratch/ilya/tpch300/customer.parquet'),
    read_parquet('/scratch/ilya/tpch300/orders.parquet'),
    read_parquet('/scratch/ilya/tpch300/lineitem.parquet')
WHERE
    o_orderkey IN (
        SELECT
            l_orderkey
        FROM
            read_parquet('/scratch/ilya/tpch300/lineitem.parquet')
        GROUP BY
            l_orderkey
        HAVING
            sum(l_quantity) > 300)
    AND c_custkey = o_custkey
    AND o_orderkey = l_orderkey
GROUP BY
    c_name,
    c_custkey,
    o_orderkey,
    o_orderdate,
    o_totalprice
ORDER BY
    o_totalprice DESC,
    o_orderdate
LIMIT 100;
