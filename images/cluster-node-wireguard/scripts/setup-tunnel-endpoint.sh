#!/bin/bash
set -e

#Define cleanup procedure
cleanup() {
    echo "Container stopped, performing cleanup..."
    export DONE=1
    wg-quick down $TUNNEL_DEVICE
}


echo -e "Setting up WireGuard tunnel on cluster node"


if [ -z "$TUNNEL_MODE" ]; then
  echo "TUNNEL_MODE not set"
  exit 1
fi

TUNNEL_MODE=$(echo $TUNNEL_MODE | tr '[:lower:]' '[:upper:]')
echo "MODE: $TUNNEL_MODE"
if [ "$TUNNEL_MODE" = "NODE" ]; then
  echo "building cluster node tunnel endpoint"

  if [ -z "$EXTERNAL_LISTEN_ADDRESS" ]; then
    echo "EXTERNAL_LISTEN_ADDRESS not set"
    exit 1
  fi
  if [ -z "$EXTERNAL_LISTEN_PORT" ]; then
    echo "EXTERNAL_LISTEN_PORT not set"
    exit 1
  fi
  if [ -z "$EXTERNAL_ALLOWED_IPS" ]; then
    echo "EXTERNAL_ALLOWED_IPS not set"
    exit 1
  fi
  if [ -z "$EXTERNAL_PUBLIC_KEY" ]; then
    echo "EXTERNAL_PUBLIC_KEY not set"
    exit 1
  fi

  if [ -z "$NODE_TUNNEL_ADDRESS" ]; then
    echo "NODE_TUNNEL_ADDRESS not set"
    exit 1
  fi

  if [ -z "$NODE_LISTEN_PORT" ]; then
    echo "NODE_LISTEN_PORT not set"
    exit 1
  fi

  if [ -z "$NODE_TUNNEL_DEVICE" ]; then
    echo "NODE_TUNNEL_DEVICE not set"
    exit 1
  fi

  if [ -z "$NODE_PRIVATE_KEY" ]; then
    echo "Generating new private key for device $NODE_TUNNEL_DEVICE"
    NODE_PRIVATE_KEY=`wg genkey` 
  fi

  if [ -z "$NODE_PUBLIC_KEY" ]; then
    echo "Generating new public key for device $NODE_TUNNEL_DEVICE"
    NODE_PUBLIC_KEY=`echo $NODE_PRIVATE_KEY | wg pubkey` 
  fi
  echo $NODE_PRIVATE_KEY > /etc/wireguard/$NODE_TUNNEL_DEVICE.key
  echo $NODE_PUBLIC_KEY > /etc/wireguard/$NODE_TUNNEL_DEVICE.pub

  cat /root/wg-node.conf.template | envsubst '$EXTERNAL_LISTEN_ADDRESS $EXTERNAL_LISTEN_PORT $EXTERNAL_ALLOWED_IPS $EXTERNAL_PUBLIC_KEY $NODE_TUNNEL_ADDRESS $NODE_LISTEN_PORT' | tee /etc/wireguard/$NODE_TUNNEL_DEVICE.conf

  ls /etc/wireguard
  export TUNNEL_DEVICE=$NODE_TUNNEL_DEVICE

else
  echo "building external tunnel endpoint"

  if [ -z "$NODE_LISTEN_ADDRESS" ]; then
    echo "NODE_LISTEN_ADDRESS not set"
    exit 1
  fi
  if [ -z "$NODE_LISTEN_PORT" ]; then
    echo "NODE_LISTEN_PORT not set"
    exit 1
  fi
  if [ -z "$NODE_ALLOWED_IPS" ]; then
    echo "NODE_ALLOWED_IPS not set"
    exit 1
  fi
  if [ -z "$NODE_PUBLIC_KEY" ]; then
    echo "NODE_PUBLIC_KEY not set"
    exit 1
  fi

  if [ -z "$EXTERNAL_TUNNEL_ADDRESS" ]; then
    echo "EXTERNAL_TUNNEL_ADDRESS not set"
    exit 1
  fi

  if [ -z "$EXTERNAL_LISTEN_PORT" ]; then
    echo "EXTERNAL_LISTEN_PORT not set"
    exit 1
  fi

  if [ -z "$EXTERNAL_TUNNEL_DEVICE" ]; then
    echo "EXTERNAL_TUNNEL_DEVICE not set"
    exit 1
  fi

  if [ -z "$EXTERNAL_PRIVATE_KEY" ]; then
    echo "Generating new private key for device $EXTERNAL_TUNNEL_DEVICE"
    EXTERNAL_PRIVATE_KEY=`wg genkey` 
  fi

  if [ -z "$EXTERNAL_PUBLIC_KEY" ]; then
    echo "Generating new public key for device $EXTERNAL_TUNNEL_DEVICE"
    EXTERNAL_PUBLIC_KEY=`echo $EXTERNAL_PRIVATE_KEY | wg pubkey` 
  fi
  echo $EXTERNAL_PRIVATE_KEY > /etc/wireguard/$EXTERNAL_TUNNEL_DEVICE.key
  echo $EXTERNAL_PUBLIC_KEY > /etc/wireguard/$EXTERNAL_TUNNEL_DEVICE.pub


  cat /root/wg-external.conf.template | envsubst '$NODE_LISTEN_ADDRESS $NODE_LISTEN_PORT $NODE_ALLOWED_IPS $NODE_PUBLIC_KEY $EXTERNAL_TUNNEL_ADDRESS $EXTERNAL_LISTEN_PORT' | tee /etc/wireguard/$EXTERNAL_TUNNEL_DEVICE.conf
  ls /etc/wireguard
  export TUNNEL_DEVICE=$EXTERNAL_TUNNEL_DEVICE
fi



#Trap SIGTERM
trap 'cleanup' SIGTERM


wg-quick up $TUNNEL_DEVICE
wg show
echo "now waiting in a loop"

while [ -z "$DONE" ]; do
	  sleep 1
done
echo "done"
