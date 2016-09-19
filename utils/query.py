from sqlalchemy import create_engine
import pandas as pd
from pygments import highlight
from pygments.lexers.sql import SqlLexer
from pygments.formatters import HtmlFormatter, LatexFormatter
from IPython import display

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


def pprint_query(filename):
    with open(filename, 'r') as handle:
        sql = handle.read()
        formatter = HtmlFormatter()
        return display.HTML('<style type="text/css">{}</style>{}'.format(
            formatter.get_style_defs('.highlight'),
            highlight(sql, SqlLexer(), formatter)))


def nbprint_and_query(filename, connection=None, use_latex=False):
    if connection is None:
        connection = get_connection()

    with open(filename, 'r') as handle:
        sql = handle.read()
        if use_latex:
            display_obj = display.Latex(highlight(
                sql, SqlLexer(), LatexFormatter()))
        else:
            formatter = HtmlFormatter()
            display_obj = display.HTML('<style type="text/css">{}</style>{}'
                .format(
                formatter.get_style_defs('.highlight'),
                highlight(sql, SqlLexer(), formatter)))

        display.display(display_obj)

        return pd.read_sql(sql, connection)
