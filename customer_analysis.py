import pandas as pd
import psycopg2
import matplotlib.pyplot as plt
import seaborn as sns
from openpyxl import Workbook
from openpyxl.styles import PatternFill, Font, Alignment
from openpyxl.chart import BarChart, Reference, PieChart

# Connection
conn = psycopg2.connect(
    host="localhost",
    database="customer_insights",
    user="postgres",
    password="postgres"
)

# Load Data
df = pd.read_sql("SELECT * FROM customers", conn)
conn.close()

print(f"Loaded {len(df)} customers")
print(df[['id','income','totalspending','segment']].head())

# Segment Summary
segment_summary = df.groupby('segment').agg(
    count=('id', 'count'),
    avg_income=('income', 'mean'),
    avg_spending=('totalspending', 'mean')
).round(2).reset_index()

print("\nSegment Summary:")
print(segment_summary)

# Channel Summary
channel_summary = pd.DataFrame({
    'Channel': ['Web', 'Catalog', 'Store'],
    'Avg_Purchases': [
        df['numwebpurchases'].mean().round(2),
        df['numcatalogpurchases'].mean().round(2),
        df['numstorepurchases'].mean().round(2)
    ]
})

print("\nChannel Summary:")
print(channel_summary)

# Children Impact
children_impact = df.groupby(df['kidhome'] + df['teenhome']).agg(
    customers=('id', 'count'),
    avg_spending=('totalspending', 'mean')
).round(2).reset_index()
children_impact.columns = ['num_children', 'customers', 'avg_spending']

print("\nChildren Impact:")
print(children_impact)

# Export to Excel
with pd.ExcelWriter('customer_insights_report.xlsx', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name='Raw Data', index=False)
    segment_summary.to_excel(writer, sheet_name='Segment Summary', index=False)
    channel_summary.to_excel(writer, sheet_name='Channels', index=False)
    children_impact.to_excel(writer, sheet_name='Children Impact', index=False)

print("\nExcel report saved!")
