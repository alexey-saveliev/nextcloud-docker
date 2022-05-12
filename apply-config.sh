#!/bin/bash

set -x

docker exec -u www-data app-server php occ --no-warnings config:system:get trusted_domains >> trusted_domain.tmp

if ! grep -q "nginx-server" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data app-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="nginx-server"
fi

if ! grep -q "app-server" trusted_domain.tmp; then
    TRUSTED_INDEX=$(cat trusted_domain.tmp | wc -l);
    docker exec -u www-data app-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="app-server"
fi

rm trusted_domain.tmp

docker exec -u www-data app-server php occ --no-warnings app:install onlyoffice

docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nginx-server/"

docker exec -u www-data app-server php occ --no-warnings config:system:set allow_local_remote_servers  --value=true

# Set HTTPS protocol usage unconditionally
#docker exec -u www-data app-server php occ --no-warnings config:system:set overwriteprotocol --value="https"

# Enable a memcache with Transactional File Locking
docker exec -u www-data app-server php occ --no-warnings config:system:set filelocking.enabled --value="true"

# Set empty user home template directory
docker exec -u www-data app-server php occ --no-warnings config:system:set skeletondirectory --value=""

# Enable LDAP module
docker exec -u www-data app-server php occ --no-warnings app:enable user_ldap
