FROM postgis/postgis:16-3.4-alpine

COPY ./setup/tune-postgis.sh /docker-entrypoint-initdb.d/tune-postgis.sh
