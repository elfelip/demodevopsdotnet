FROM mongo:4.0.12-xenial

ENV DATA_PATH=/mongo/data
ENV MONGO_INITDB_DATABASE=BookstoreDb
ENV MONGO_INITDB_ROOT_USERNAME=mongoadmin
ENV MONGO_INITDB_ROOT_PASSWORD=secret
ADD initbookstoredb.sh /docker-entrypoint-initdb.d/initbookstoredb.sh
RUN chmod a+x /docker-entrypoint-initdb.d/initbookstoredb.sh
