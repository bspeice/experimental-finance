from sqlalchemy import create_engine
import pandas as pd

CONNECTION_STRING = 'mssql+pymssql://IVYuser:resuyvi@vita.ieor.columbia.edu'


def get_connection():
    engine = create_engine(CONNECTION_STRING)
    return engine.connect()


def query_dataframe(query, connection=None):
    if connection is None:
        connection = get_connection()
    return pd.read_sql(query, connection)


def query_dataframe_f(filename, connection=None):
    if connection is None:
        connection = get_connection()
    with open(filename, 'r') as handle:
        return pd.read_sql(handle.read(), connection)


def print_and_query(filename, connection=None):
    if connection is None:
        connection = get_connection()
    with open(filename, 'r') as handle:
        sql = handle.read()
        print(sql)
        return pd.read_sql(sql, connection)