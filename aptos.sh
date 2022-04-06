#!/bin/bash
echo "=================================================="
echo -e "\033[0;35m"
echo " _______ _                    _               _______        _   _   _      _   _____              ";
echo "|__   __| |                  (_)             |__   __|      | | | \ | |    | | |  __ \             ";
echo "   | |  | |__  _ __ __ _  ___ _  __ _ _ __      | | ___  ___| |_|  \| | ___| |_| |__) |   _ _ __   ";
echo "   | |  | '_ \| '__/ _` |/ __| |/ _` | '_ \     | |/ _ \/ __| __| . ` |/ _ \ __|  _  / | | | '_ \  ";
echo "   | |  | | | | | | (_| | (__| | (_| | | | |    | |  __/\__ \ |_| |\  |  __/ |_| | \ \ |_| | | | | ";
echo "   |_|  |_| |_|_|  \__,_|\___|_|\__,_|_| |_|    |_|\___||___/\__|_| \_|\___|\__|_|  \_\__,_|_| |_| ";                                                                                                 
echo -e "\e[0m"
echo "=================================================="

sleep 2


sudo apt-get update
sudo apt-get install jq -y
# Installing yq to modify yaml files
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq
cd $HOME
echo -e "\e[1m\e[32m1. Dependencies updated... \e[0m" && sleep 1
echo "=================================================="

echo -e "\e[1m\e[32m2. Checking if Docker is installed... \e[0m" && sleep 1

if ! command -v docker &> /dev/null
then

    sudo apt-get install ca-certificates curl gnupg lsb-release wget -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    echo -e "\e[1m\e[32m2.1 Docker Installed... \e[0m" && sleep 1
fi

echo "=================================================="

echo -e "\e[1m\e[32m3. Checking if Docker Compose is installed ... \e[0m" && sleep 1

docker compose version &> /dev/null
if [ $? -ne 0 ]
then

    mkdir -p ~/.docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    sudo chown $USER /var/run/docker.sock
    echo -e "\e[1m\e[32m3.1 Docker Compose v2.3.3 Installed... \e[0m" && sleep 1
fi

echo "=================================================="



sudo mkdir -p $HOME/aptos/identity
cd $HOME/aptos
if [ -f $HOME/aptos/docker-compose.yaml ]
then
    docker compose down -v
fi
docker pull aptoslab/validator:devnet
docker pull aptoslab/tools:devnet
rm *
rm $HOME/aptos/identity/id.json
wget -P $HOME/aptos https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/docker-compose.yaml
wget -P $HOME/aptos https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml
wget -P $HOME/aptos https://devnet.aptoslabs.com/genesis.blob
wget -P $HOME/aptos https://devnet.aptoslabs.com/waypoint.txt
#wget -P $HOME/aptos https://raw.githubusercontent.com/aykutarda/aykutarda/main/seed.yaml

echo -e "\e[1m\e[32m4. Aptos FullNode config files downloaded ... \e[0m" && sleep 1
echo "=================================================="

# Checking if aptos node identity exists
create_identity(){
    echo -e "\e[1m\e[32m4.1 Creating a unique node identity \e[0m"  
    docker run --rm --name aptos_tools -d -i aptoslab/tools:devnet &> /dev/null
    docker exec -it aptos_tools aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file $HOME/private-key.txt | grep 'Success' &> /dev/null
    if [ $? == 0 ]; then
        docker exec -it aptos_tools cat $HOME/private-key.txt > $HOME/aptos/identity/private-key.txt
        docker exec -it aptos_tools aptos-operational-tool extract-peer-from-file --encoding hex --key-file $HOME/private-key.txt --output-file $HOME/peer-info.yaml &> /dev/null
        docker exec -it aptos_tools cat $HOME/peer-info.yaml > $HOME/aptos/identity/peer-info.yaml
        PEER_ID=$(sed -n 5p $HOME/aptos/identity/peer-info.yaml | sed 's/    - \(.*\)/\1/')
        PEER_ID=${PEER_ID//$'\r'/}
        PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)

        echo -e "\e[1m\e[92m Identity was successfully created \e[0m"
        echo -e "\e[1m\e[92m Peer Id: \e[0m" $PEER_ID
        echo -e "\e[1m\e[92m Private Key:  \e[0m" $PRIVATE_KEY
    else
        rm -rf $HOME/aptos

        echo -e "\e[1m\e[93m\e[5m\e[4mWARNING/ОШИБКА\e[0m\n"
        echo -e "\e[1m\e[93m Unfortunately you won't be able to run Aptos Full Node through Docker on this server due to outdated hardware, either change the server or use Option 1 from the guide \e[0m"
        echo -e "\e[1m\e[1m\e[4mENG Guide: https://ohsnail.com/aptos-fullnode-docker-guide-eng/ \n\e[0m"

        echo -e "\e[1m\e[93m К сожалению вы не сможете запустить Aptos Ноду при помощи Docker на вашем сервера из-за устаревшего оборудования, поменяйте сервер или воспользуйтесь Вариант 1 из гайда \e[0m"
        echo -e "\e[1m\e[1m\e[4mRU Гайд: https://ohsnail.com/aptos-fullnode-docker-guide/ \n\e[0m"
        docker stop aptos_tools &> /dev/null
        exit
    fi
    docker stop aptos_tools &> /dev/null
}

if [[ -f $HOME/aptos/identity/peer-info.yaml && -f $HOME/aptos/identity/private-key.txt ]]
then

    PEER_ID=$(sed -n 5p $HOME/aptos/identity/peer-info.yaml | sed 's/    - \(.*\)/\1/')
    PEER_ID=${PEER_ID//$'\r'/}
    PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
    
    if [ ! -z "$PRIVATE_KEY" ]
    then
        echo -e "\e[1m\e[92m Peer Id: \e[0m" $PEER_ID
        echo -e "\e[1m\e[92m Private Key:  \e[0m" $PRIVATE_KEY
    else
        rm $HOME/aptos/identity/peer-info.yaml
        rm $HOME/aptos/identity/private-key.txt
        create_identity
    fi
    echo "=================================================="
else

    create_identity
    echo "=================================================="
fi

# Setting node identity
/usr/local/bin/yq e -i '.full_node_networks[] +=  { "identity": {"type": "from_config", "key": "'$PRIVATE_KEY'", "peer_id": "'$PEER_ID'"} }' $HOME/aptos/public_full_node.yaml

# Setting peer list
#/usr/local/bin/yq ea -i 'select(fileIndex==0).full_node_networks[0].seeds = select(fileIndex==1).seeds | select(fileIndex==0)' $HOME/aptos/public_full_node.yaml $HOME/aptos/seeds.yaml
#rm $HOME/aptos/seeds.yaml

# Add possibility to share your node as a peer
/usr/local/bin/yq e -i '.full_node_networks[].listen_address="/ip4/0.0.0.0/tcp/6180"' $HOME/aptos/public_full_node.yaml
/usr/local/bin/yq e -i '.services.fullnode.ports +=  "6180:6180"' $HOME/aptos/docker-compose.yaml

echo -e "\e[1m\e[32m5. Starting Aptos FullNode ... \e[0m" && sleep 1

docker compose up -d

echo "=================================================="

echo -e "\e[1m\e[32mAptos FullNode Started \e[0m"

echo "=================================================="


echo -e "\e[1m\e[32mPrivate key file location. You Should Back Up Your Private Key: \e[0m" 
echo -e "\e[1m\e[39m"    $HOME/aptos/identity/private-key.txt" \n \e[0m"

echo -e "\e[1m\e[32mPeer info file location. You Should Back Up Your Files: \e[0m" 
echo -e "\e[1m\e[39m"    $HOME/aptos/identity/peer-info.yaml" \n \e[0m"

echo -e "\e[1m\e[32mTo check sync status: \e[0m" 
echo -e "\e[1m\e[39m    curl 127.0.0.1:9101/metrics 2> /dev/null | grep aptos_state_sync_version | grep type \n \e[0m" 

echo -e "\e[1m\e[32mTo view logs: \e[0m" 
echo -e "\e[1m\e[39m    docker logs -f aptos-fullnode-1 --tail 5000 \n \e[0m" 

echo -e "\e[1m\e[32mTo stop: \e[0m" 
echo -e "\e[1m\e[39m    docker compose stop \n \e[0m" 
