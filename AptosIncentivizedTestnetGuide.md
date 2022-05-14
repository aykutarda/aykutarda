# AptosIncentivizedTestNet-Guide
Aptos Ödüllü Test Ağı İçin Nasıl Node Kurulur.

## <a name='İçerik'></a>İçerik

* [1. Gereklilikler](#1-gereklilikler)
* [2. Adım Adım Kurulum](#2-adım-adım-kurulum)

## 1. Gereklilikler

**Testnet İçin Bir Doğrulayıcı Kurmak İstiyorsanız İhtiyacınız Olan Sistem Gereksinimleri**:

**CPU**: 4 cores
**Memory**: 8GiB RAM

## 2. Adım Adım Kurulum

**İlk Adım Screen ve Vars Kurulumu**

```
sudo apt install screen

screen -S homepage

echo "export WORKSPACE=testnet" >> $HOME/.bash_profile

echo "export PUBLIC_IP=$(curl -s ifconfig.me)" >> $HOME/.bash_profile

source $HOME/.bash_profile

```

## 2. Adım Paketlerin Güncellenmesi ve Bağımlılıkların Oluşturulması

```
sudo apt update && sudo apt upgrade -y

sudo apt-get install jq unzip -y

```


## 3. Adım Docker ve Docker Compose Kurulumu
```
sudo apt-get install ca-certificates curl gnupg lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

mkdir -p ~/.docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

chmod +x ~/.docker/cli-plugins/docker-compose

sudo chown $USER /var/run/docker.sock

```

## 5. Adım Aptos CLI Kurulumu

```
wget -qO aptos-cli.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip

unzip aptos-cli.zip -d /usr/local/bin

chmod +x /usr/local/bin/aptos

rm aptos-cli.zip

```

## 6. Adım Validatör Node Kurulumu

### Dizin Oluşturma

```
mkdir ~/$WORKSPACE && cd ~/$WORKSPACE

```

### Yapılandırma Dosyalarını İndirme

```
wget -qO docker-compose.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml

wget -qO validator.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml

wget -qO fullnode.yaml https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml

```

### Anahtarları Oluşturma

Bu adımda şu 3 dosya oluşturulacaktır: `private-keys.yaml`, `validator-identity.yaml`, `validator-full-node-identity.yaml`
```
aptos genesis generate-keys --output-dir ~/$WORKSPACE

```
**Önemli**: *Anahtar dosyalarınızı güvenli bir yere yedekleyin. Bu anahtar dosyalar, düğümünüzün sahipliğini oluşturmanız için önemlidir,
ve bu bilgileri daha sonra uygunsa ödüllerinizi talep etmek için kullanacaksınız. Bu anahtarları asla başkalarıyla paylaşmayın.*

### Doğrulayıcınızı Yapılandırın

```
aptos genesis set-validator-configuration \
  --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
  --username testnetrun \
  --validator-host $PUBLIC_IP:6180 \
  --full-node-host $PUBLIC_IP:6182
  
```

**NOT**: *"testnetrun" yazan yere size ait kullanıcı adını yazın. "$PUBLIC_IP" kısımlarını kiralamış olduğunuz vpn sunucusunun ip adresi ile değiştirin.*
  
### Root key oluşturun
```
mkdir keys
aptos key generate --output-file keys/root
```

### Layout dosyası oluşturun.
```
tee layout.yaml > /dev/null <<EOF
---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
  - testnetrun
chain_id: 23
EOF

```
**NOT**: *"testnetrun" yazan kısma bir önceki adımda belirlediğiniz kullanıcı adını yazın.*

### APTOS Framework'ünü indirin.

```
wget -qO framework.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip framework.zip
rm framework.zip

```

### Genesis blob ve waypoint'i derleyin.

```
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
```

### Docker compose'u çalıştırın.

```
docker compose up -d

```

**Tebrikler , içerdesiniz.**

### Yarayışlı Linkler

### Senkronize durumunuzu kontrol edin

```
https://aptos-node.info/

```
