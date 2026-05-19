{ writeShellScriptBin, minio }:

let
  serveraddr = "192.168.1.1";
  clientaddr = "192.168.1.2";
  # servernic = "enp193s0f0v0";
  # clientnic = "enp193s0f1v0";
  servernic = "enp193s0f0np0";
  clientnic = "enp193s0f1np1";
  ssd="nvme2n1";
in
writeShellScriptBin "nic_minio" ''
  CMD="${minio}/bin/minio server $HOME/minio-data --address '${serveraddr}:9000' --console-address '${serveraddr}:9001'"

  sudo modprobe ice

  mkdir -p $HOME/minio-data
  sudo mount /dev/${ssd} ~/minio-data
  sudo chown -R $USER $HOME/minio-data

  sudo ip netns add ns_server
  sudo ip netns add ns_client

  sudo ip link set ${servernic} netns ns_server
  sudo ip netns exec ns_server ip link set dev ${servernic} mtu 9000
  sudo ip netns exec ns_server ip addr add dev ${servernic} ${serveraddr}/24
  sudo ip netns exec ns_server ip link set dev ${servernic} up

  sudo ip link set ${clientnic} netns ns_client
  sudo ip netns exec ns_client ip link set dev ${clientnic} mtu 9000
  sudo ip netns exec ns_client ip addr add dev ${clientnic} ${clientaddr}/24
  sudo ip netns exec ns_client ip link set dev ${clientnic} up

  sudo ip netns exec ns_server su -c "$CMD" $USER

  sudo ip netns del ns_server
  sudo ip netns del ns_client

  sudo umount $HOME/minio-data
''
