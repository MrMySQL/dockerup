#!/usr/bin/env bash

BASE_DIR="$(dirname "$0")";

source "$BASE_DIR/config.sh";
source "$BASE_DIR/lib.sh";
source "$BASE_DIR/params.sh";
source "$BASE_DIR/init.sh";

CONTAINER_PATH="$CONTAINERS_DIR_PATH/$TICKET_NUMBER";

# Create dir for project
if [ ! -d "$CONTAINER_PATH" ]; then
    log "Create $CONTAINER_PATH";
    mkdir -p "$CONTAINER_PATH"
fi

# Create docker-compose.yml
if [ ! -f "$CONTAINER_PATH/docker-compose.yml" ]; then
    log "Create $CONTAINER_PATH/docker-compose.yml";
    cp "$BASE_DIR/template/docker-compose.yml" "$CONTAINER_PATH/docker-compose.yml"
fi

sed -i '' s/%id%/"$TICKET_NUMBER"/g "$CONTAINER_PATH"/docker-compose.yml;
sed -i '' s/%img%/"$DOCKER_IMAGE_NAME"/g "$CONTAINER_PATH"/docker-compose.yml;

# Run container
cd $CONTAINER_PATH
log "Run container '$TICKET_NUMBER'";
docker-compose up -d;

# Create host config
log "Create host config '~/.ssh/cnt_cnf/$TICKET_NUMBER'";
cp "$BASE_DIR/template/hostconf" ~/.ssh/cnt_cnf/"$TICKET_NUMBER";
sed -i '' s/%host%/"$TICKET_NUMBER"/g ~/.ssh/cnt_cnf/"$TICKET_NUMBER";
sed -i '' s/%ssh_port%/"$TICKET_NUMBER"3/g ~/.ssh/cnt_cnf/"$TICKET_NUMBER";

# Mount container volume to the host
sleep 3;
log "Mount container volume to the host '$CONTAINER_PATH/src/'";
mkdir -p "$CONTAINER_PATH/src";
sshfs "$TICKET_NUMBER":/var/www/html/ "$CONTAINER_PATH/src/" -ocache=no;
