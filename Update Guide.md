# AptosFullNode-Update-Guide
How can i update my full node for aptos.

## <a name='İçerik'></a>İçerik

* [1. Update Step By Step](#2-update-guide-step-by-step)

## 1. Update Step By Step

**If you have these files, delete the inside of this folder completely. var/lib/docker/volumes/aptos_db/_data**

```cd aptos```

```docker compose stop```

```rm genesis.blob```

```rm waypoint.txt```

```rm public_full_node.yaml```

```wget https://devnet.aptoslabs.com/genesis.blob```

```wget https://devnet.aptoslabs.com/waypoint.txt```

```wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/public_full_node/public_full_node.yaml```

```docker compose restart```
