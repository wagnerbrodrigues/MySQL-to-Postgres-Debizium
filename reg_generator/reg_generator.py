import time
import mysql.connector
from mysql.connector import Error
import random

# Função para verificar se o MySQL está pronto
def wait_for_mysql():
    while True:
        try:
            connection = mysql.connector.connect(
                host="mysql",
                user="user",
                password="userpass",
                database="testdb",
                port=3306
            )
            if connection.is_connected():
                print("MySQL está pronto!")
                return connection
        except Error:
            print("Aguardando MySQL...")
            time.sleep(5)

# Função para gerar operações aleatórias no MySQL
def generate_operations():
    connection = wait_for_mysql()
    cursor = connection.cursor()
    
    cursor.execute('''CREATE TABLE IF NOT EXISTS customers (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        name VARCHAR(255),
                        email VARCHAR(255)
                    )''')
    connection.commit()

    operations = ['INSERT', 'UPDATE', 'DELETE']
    
    while True:
        operation = random.choice(operations)

        if operation == 'INSERT':
            name = random.choice(["Alice", "Bob", "Charlie", "David", "Eva"])
            email = f"{name.lower()}@example.com"
            cursor.execute("INSERT INTO customers (name, email) VALUES (%s, %s)", (name, email))
            print(f"INSERT: {name}, {email}")
        
        elif operation == 'UPDATE':
            cursor.execute("SELECT id FROM customers ORDER BY RAND() LIMIT 1")
            result = cursor.fetchone()
            if result:
                new_email = f"updated_{result[0]}@example.com"
                cursor.execute("UPDATE customers SET email = %s WHERE id = %s", (new_email, result[0]))
                print(f"UPDATE: ID {result[0]}, New email {new_email}")
        
        elif operation == 'DELETE':
            cursor.execute("SELECT id FROM customers ORDER BY RAND() LIMIT 1")
            result = cursor.fetchone()
            if result:
                cursor.execute("DELETE FROM customers WHERE id = %s", (result[0],))
                print(f"DELETE: ID {result[0]}")

        connection.commit()
        time.sleep(1)

if __name__ == "__main__":
    generate_operations()
