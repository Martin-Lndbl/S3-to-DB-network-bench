{ writeShellScriptBin, minio }:

let
  serveraddr = "192.168.1.1";
  clientaddr = "192.168.1.2";
  servernic = "enp193s0f0np0";
  clientnic = "enp193s0f1np1";
in
writeShellScriptBin "minio-server" ''
  mkdir -p $HOME/minio-data
  sudo mount $HOME/minio-data
  sudo chown $USER $HOME/minio-data 

  sudo ip netns del ns_server
  sudo ip netns del ns_client

  sudo ip netns add ns_server
  sudo ip netns add ns_client

  sudo ip link set enp193s0f0np0 netns ns_server
  sudo ip netns exec ns_server ip link set dev ${servernic} mtu 9000
  sudo ip netns exec ns_server ip addr add dev ${servernic} ${serveraddr}/24
  sudo ip netns exec ns_server ip link set dev ${servernic} up

  sudo ip link set enp193s0f1np1 netns ns_client
  sudo ip netns exec ns_client ip link set dev ${clientnic} mtu 9000
  sudo ip netns exec ns_client ip addr add dev ${clientnic} ${clientaddr}/24
  sudo ip netns exec ns_client ip link set dev ${clientnic} up

  sudo ip netns exec ns_server ${minio}/bin/minio server $HOME/minio-data --address "${serveraddr}:9000" --console-address "${serveraddr}:9001"
''
