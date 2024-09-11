# Creating table
# %%sql
# CREATE DATABASE IF NOT EXISTS climate;
spark.sql("CREATE DATABASE IF NOT EXISTS climate")

# %%sql
# CREATE TABLE IF NOT EXISTS climate.weather (
#     datetime              timestamp,
#     temp                  double,
#     lat                   double,
#     long                  double,
#     cloud_coverage        string,
#     precip                double,
#     wind_speed            double
# )
# USING iceberg
# PARTITIONED BY (days(datetime))
spark.sql("CREATE TABLE IF NOT EXISTS climate.weather ( \
    datetime              timestamp, \
    temp                  double, \
    lat                   double, \
    long                  double, \
    cloud_coverage        string, \
    precip                double, \
    wind_speed            double \
) \
USING iceberg \
PARTITIONED BY (days(datetime))")

# Writing data
from datetime import datetime
schema = spark.table("climate.weather").schema
data = [
    (datetime(2023,8,16), 76.2, 40.951908, -74.075272, "Partially sunny", 0.0, 3.5),
    (datetime(2023,8,17), 82.5, 40.951908, -74.075272, "Sunny", 0.0, 1.2),
    (datetime(2023,8,18), 70.9, 40.951908, -74.075272, "Cloudy", .5, 5.2)
  ]
df = spark.createDataFrame(data, schema)
df.writeTo("climate.weather").append()


# Reading data
from pyiceberg.catalog import load_catalog
from pyiceberg.expressions import GreaterThanOrEqual

catalog = load_catalog("default")
tbl = catalog.load_table("climate.weather")

sc = tbl.scan(row_filter=GreaterThanOrEqual("datetime", "2023-08-01T00:00:00.000000+00:00"))
df = sc.to_arrow().to_pandas()
