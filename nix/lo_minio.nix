{ writeShellScriptBin, minio }:

let
  serveraddr = "localhost";
  ssd = "nvme2n1";
in
writeShellScriptBin "lo_minio" ''

  mkdir -p $HOME/minio-data
  sudo mount /dev/${ssd} ~/minio-data
  sudo chown -R $USER $HOME/minio-data

  ${minio}/bin/minio server $HOME/minio-data --address '${serveraddr}:9000' --console-address '${serveraddr}:9001' 2>&1 &

  MINIO_PID=$!
  echo "TOKILL: $MINIO_PID"

  wait $MINIO_PID

  sudo umount $HOME/minio-data
''
