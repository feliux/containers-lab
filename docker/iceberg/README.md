# Iceberg Tabular Docker stack

```sh
$ git clone git@github.com:tabular-io/docker-spark-iceberg.git
$ cd docker-spark-iceberg
$ docker-compose up -d
$ docker exec -it spark-iceberg pyspark
```

Minio available on `http://localhost:9001/browser` with `admin /// password`.

## References

[Github repository](https://github.com/tabular-io/docker-spark-iceberg)

[Creating an Iceberg table](https://iceberg.apache.org/spark-quickstart/#creating-a-table)

[A Developer’s Introduction to Apache Iceberg using MinIO](https://blog.min.io/a-developers-introduction-to-apache-iceberg-using-minio/)

[Building a Data Lakehouse using Apache Iceberg and MinIO](https://blog.min.io/building-a-data-lakehouse-using-apache-iceberg-and-minio/)
