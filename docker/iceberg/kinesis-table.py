from pyspark.sql.types import LongType, DateType, StructType, StructField, StringType
from pyspark.sql.functions import current_date
import datetime

CatalogDatabaseTable = "demo.dev.my_kinesis_table"

# Create table
schema = StructType([
  StructField("timestamp", LongType(), True),
  StructField("datedatapart", DateType(), True),
  StructField("tenantid", StringType(), True),
  StructField("clientid", StringType(), True),
  StructField("resource", StringType(), True)
])
df = spark.createDataFrame([], schema)
df.writeTo(CatalogDatabaseTable).create()

# Write table data
schema = spark.table(CatalogDatabaseTable).schema
data = [
    (10000000000548, datetime.date(1111, 1, 1), "test", "test", "/test"),
    (10000000000548, datetime.date(2222, 2, 2), "test", "test", "/test")
]
df = spark.createDataFrame(data, schema)
df.writeTo(CatalogDatabaseTable).append()

# Read table
df = spark.table(CatalogDatabaseTable).show()
