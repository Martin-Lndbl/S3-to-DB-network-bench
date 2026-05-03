SELECT
    nation,
    o_year,
    sum(amount) AS sum_profit
FROM (
    SELECT
        n_name AS nation,
        extract(year FROM o_orderdate) AS o_year,
        l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity AS amount
    FROM
        read_parquet('/scratch/ilya/tpch300/part.parquet'),
        read_parquet('/scratch/ilya/tpch300/supplier.parquet'),
        read_parquet('/scratch/ilya/tpch300/lineitem.parquet'),
        read_parquet('/scratch/ilya/tpch300/partsupp.parquet'),
        read_parquet('/scratch/ilya/tpch300/orders.parquet'),
        read_parquet('/scratch/ilya/tpch300/nation.parquet')
    WHERE
        s_suppkey = l_suppkey
        AND ps_suppkey = l_suppkey
        AND ps_partkey = l_partkey
        AND p_partkey = l_partkey
        AND o_orderkey = l_orderkey
        AND s_nationkey = n_nationkey
        AND p_name LIKE '%green%') AS profit
GROUP BY
    nation,
    o_year
ORDER BY
    nation,
    o_year DESC;
