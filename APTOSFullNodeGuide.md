# AptosFullNode-Guide
How can i create full node for aptos.

## <a name='İçerik'></a>İçerik

* [1. Requirements](#1-requirements)
* [2. Setup Step By Step](#2-setup-guide-step-by-step)

## 1. Requirements

**If running the Fullnode for development or testing purpose**:

**CPU**: 2 cores
**Memory**: 4GiB RAM

**For running a production grade Fullnode we recommend using hardware with**:

**CPU**: Intel Xeon Skylake or newer, 4 cores
**Memory**: 8GiB RAM

## 2. Setup Step By Step

**First Step Install Screen and Docker**

```sudo apt install screen```

```screen -S homepage```

```sudo apt update```

```sudo apt install ca-certificates curl gnupg lsb-release wget -y```

```curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg```

```echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null```

```sudo apt update```

```sudo apt install docker-ce docker-ce-cli containerd.io -y```


**Second Step Install Docker Compose**

```mkdir -p ~/.docker/cli-plugins/```

```curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose```

```chmod +x ~/.docker/cli-plugins/docker-compose```

```sudo chown $USER /var/run/docker.sock```

**Third Step Create a Folder Aptos in Which We Will Download Config Files**

```mkdir $HOME/aptos```

```cd $HOME/aptos```

```wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml```

```wget https://raw.githubusercontent.com/aykutarda/aykutarda/main/public_full_node.yaml```

```wget https://devnet.aptoslabs.com/genesis.blob```

```wget https://devnet.aptoslabs.com/waypoint.txt```

**Fourth Step Launching The Node**

```docker compose up -d```

Well done , you are in.

**Useful Codes**

**Checking the sync status**

```curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type```

**Look Logs**

```docker logs -f aptos-fullnode-1 --tail 5000```
