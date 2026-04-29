{
  writeShellScriptBin,
  minio,
  minio-client,
  xfsprogs,
}:

let
  ssd = "nvme2n1";
in
writeShellScriptBin "minio-server" ''
  mkdir -p $HOME/minio-data

  ${xfsprogs}/bin/mkfs.xfs /dev/${ssd}

  sudo mount /dev/${ssd} ~/minio-data
  sudo chown $USER $HOME/minio-data 

  ${minio}/bin/minio server $HOME/minio-data --address "localhost:9000" --console-address "localhost:9001" &
  sleep 3

  ${minio-client}/bin/mc alias set 's' 'http://localhost:9000' 'minioadmin' 'minioadmin'
  ${minio-client}/bin/mc mb s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/customer.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/lineitem.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/nation.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/orders.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/part.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/partsupp.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/region.parquet s/tpch300
  ${minio-client}/bin/mc put /scratch/ilya/tpch300/supplier.parquet s/tpch300

  kill %1

  sudo umount $HOME/minio-data
''
