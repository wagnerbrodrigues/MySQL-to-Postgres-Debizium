FROM confluentinc/cp-kafka-connect:7.5.0

# Instalar o conector JDBC
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.4.0

# Instalar o conector Debezium MySQL
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.9.7
