import sys

sys.path.append('../utils/')

from query import query_dataframe_f

q2_data = query_dataframe_f('Q2_atm_tt.sql')
q2_data.to_csv('q2_data_tt.csv')
