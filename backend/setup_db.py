import mysql.connector
import os

# 数据库配置
DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "Ac661978",
    "database": "mioflow"
}

def execute_sql_file(filename):
    try:
        # 读取SQL文件
        with open(filename, 'r') as file:
            sql_commands = file.read()

        # 连接到数据库
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # 执行SQL命令
        for command in sql_commands.split(';'):
            if command.strip():
                cursor.execute(command)
        
        # 提交更改
        conn.commit()
        print("数据库初始化成功！")

    except Exception as e:
        print(f"错误: {str(e)}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    # 获取schema.sql的路径
    current_dir = os.path.dirname(os.path.abspath(__file__))
    schema_file = os.path.join(current_dir, 'schema.sql')
    
    # 执行SQL文件
    execute_sql_file(schema_file)