#!/bin/bash

# Inicia os containers
docker-compose down
docker-compose up --build -d

# Aguardar o MySQL estar pronto
echo "Aguardando MySQL iniciar..."
sleep 20

# Executa os GRANTs para configurar permissões no MySQL
echo "Concedendo permissões no MySQL..."
docker exec -it mysql mysql -uroot -prootpassword -e "GRANT REPLICATION SLAVE, REPLICATION CLIENT, REPLICATION_APPLIER, RELOAD, FLUSH_TABLES ON *.* TO 'user'@'%'; GRANT ALL PRIVILEGES ON testdb.* TO 'user'@'%'; FLUSH PRIVILEGES;"
docker exec -it postgres bash -c "PGPASSWORD='userpass' psql -U user -d postgres -c 'CREATE SCHEMA testedb;'"

# Configura o conector Debezium para MySQL
echo "Configurando o conector Debezium para MySQL..."
curl -i -X POST  -H "Accept:application/json" -H  "Content-Type:application/json" -d '{
    "name": "from mysql",
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "tasks.max": "1",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "user",
        "database.password": "userpass",
        "database.server.id": "1",
	      "database.server.name": "dbserver1",
        "topic.prefix": "from_mysql",
        "table.include.list": "testdb.customers",
        "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
        "schema.history.internal.kafka.topic": "schema-changes.customers",
        "transforms": "route",
        "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
        "transforms.route.replacement": "from_mysql_$3"
    }
}' http://localhost:8083/connectors/ 


echo "Configurando o conector Debezium para Postgres..."
# Configura o conector JDBC para Postgres
curl -i -X POST  -H "Accept:application/json" -H "Content-Type:application/json" -d '{
    "name": "to-postgres",
    "config": {
        "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
        "topics": "from_mysql_customers",
        "connection.url": "jdbc:postgresql://postgres:5432/postgres?currentSchema=testedb",
        "connection.username": "user",
        "connection.password": "userpass",
        "auto.create": "true",
        "insert.mode": "upsert",
        "delete.enabled": "true",
        "primary.key.fields": "id",
        "primary.key.mode": "record_key",
        "schema.evolution": "basic"
    }
}' http://localhost:8083/connectors/

echo "Conectores configurados com sucesso!"
