import pandas as pd
import mysql.connector
from utils import get_conn
from sqlalchemy import create_engine


if __name__ == "__main__":
    conn = get_conn()
    engine = create_engine(conn, echo=False)
    df = pd.read_sql('SELECT * FROM devices', engine)
    df.to_csv('devices.csv', index=False)
