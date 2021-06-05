#!/bin/bash

# Vars
IMAGE="docker-php"
HOST="localhost"
PHP="5.6"
SRC=""
WWW=""

# Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)
            IMAGE="$2"
            shift
            shift
            ;;
        --host)
            HOST="$2"
            shift
            shift
            ;;
        --src)
            SRC="$2"
            shift
            shift
            ;;
        --www)
            WWW="$2"
            shift;
            shift;
            ;;
        --php)
            PHP="$2"
            shift
            shift
            ;;
            *)
            shift
            ;;
    esac
done

echo "[INFO] Checking arguments..."

if [ -z "$SRC" ]; then echo "[ERROR] Missing argument: --src /path/to/source"; exit; fi
if [ -z "$HOST" ]; then echo "[ERROR] Missing argument: --host nice.app"; exit; fi
if ! [ -d "$SRC" ]; then echo "[ERROR] Source path not found: $SRC"; exit; fi

echo "[INFO] Setting Dockerfile..."

{ cp Dockerfile Dockerfile-tmp; } || { exit; }
{ sed -i "s/{host}/$HOST/g" Dockerfile-tmp; } || { exit; }
{ sed -i "s/{phpver}/$PHP/g" Dockerfile-tmp; } || { exit; }

echo "[INFO] Configuring Apache..."

{ cp apache.conf apache-tmp.conf; } || { exit; }
{ sed -i "s/html/$WWW/g" apache-tmp.conf; } || { exit; }
{ sed -i "s/localhost/$HOST/g" apache-tmp.conf; } || { exit; }

if ! [ -d "ssl/$HOST" ]; then { mkdir -p ssl/$HOST; } || { exit; }; fi

echo "[INFO] Generating SSL cert..."

{ openssl genrsa -out ssl/$HOST/server.key 2048 &> /dev/null; } || { exit; }
{ openssl req -new -key ssl/$HOST/server.key -sha256 -out ssl/$HOST/server.csr -subj "/CN=$HOST" &> /dev/null; } || { exit; }
{ openssl x509 -req -days 365 -in ssl/$HOST/server.csr -signkey ssl/$HOST/server.key -sha256 -out ssl/$HOST/server.crt &> /dev/null; } || { exit; }

echo "[INFO] Building service image..."

{ docker build -f Dockerfile-tmp -t $IMAGE .; } || { exit; }

if ! [ -z "$(docker ps -a | grep $HOST)" ]; then

	echo "[WARN] Removing old container..."
    
	{ docker stop $HOST &> /dev/null; } || { exit; }
	{ docker rm $HOST &> /dev/null; } || { exit; }

fi

if [ -z "$(docker network ls | grep $HOST)" ]; then

    echo "[INFO] Creating network $HOST..."

    { docker network create $HOST &> /dev/null; } || { exit; }

fi

echo "[INFO] Creating service container..."

{ docker run --restart always --name $HOST --network $HOST -v $SRC:/var/www -d $IMAGE &> /dev/null; } || { exit; }

if [ -f "$SRC/composer.json" ]; then

    if ! [ -d "$SRC/vendor" ]; then

        echo "[INFO] Downloading dependencies with composer..."
        { docker exec -i $HOST bash -c "cd /var/www && rm composer.lock && curl -s https://getcomposer.org/composer.phar -o composer.phar && php composer.phar install --no-interaction" &> /dev/null; } || { exit; }

    fi

fi

echo "[INFO] Removing temporary files..."

rm apache-tmp.conf &> /dev/null
rm Dockerfile-tmp &> /dev/null

echo "[INFO] Service deploy time: $(($SECONDS / 60))m$(($SECONDS % 60))s"

