
# MySQL to Postgres Replication with Debezium

This project sets up real-time data replication from MySQL to PostgreSQL using Kafka and Debezium. Changes made in the MySQL database are captured and replicated into PostgreSQL automatically.

## Quick Start

1. **Clone the repository**:

    ```bash
    git clone https://github.com/wagnerbrodrigues/MySQL-to-Postgres-Debizium.git
    cd MySQL-to-Postgres-Debizium
    ```

2. **Start the services**:

    Simply run the `start.sh` script to start the Docker services and configure the connectors:

    ```bash
    ./start.sh
    ```

    This will start MySQL, PostgreSQL, Kafka, Zookeeper, and Kafka Connect, and configure the Debezium MySQL connector and the JDBC PostgreSQL connector.

## Project Files

- **`docker-compose.yml`**: Defines the Docker services for MySQL, PostgreSQL, Kafka, and other components.
- **`start.sh`**: Script to start the containers and configure the Debezium and JDBC connectors.
- **`reg_generator/`**: Contains files for generating records in MySQL:
  - **`Dockerfile`**: Builds the Python image to run the generator.
  - **`reg_generator.py`**: Python script that generates random records in MySQL to be propagated to PostgreSQL.
  - **`requirements.txt`**: Contains the dependencies needed to run `reg_generator.py`.
- **`README.md`**: This file, describing the project setup.

## How it Works

1. MySQL changes are captured using Debezium.
2. Kafka acts as the message broker.
3. PostgreSQL receives the changes and applies them in real-time.

## Troubleshooting

If you encounter any issues, check the logs using:

```bash
docker logs connect
```

Make sure that all services are running and the connectors are properly configured.

## License

This project is licensed under the MIT License.
