# MSSQL

Set up a Microsoft SQL Server.

## Deployment

Deploy services running the following command `$ docker-compose up -d`. Destroy with `$ docker-compose down -v`.

## Usage

**Connect to mssql**

```sh
# Connect
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Changeme!

# Populate some data
> create database myddbb;
> go
> use myddbb;
> create table transactions(ccnum varchar(32), date date, amount decimal(7,2), cvv char(4), exp date);
> go
> insert into transactions(ccnum, date, amount, cvv, exp) values ('4444333322221111', '2019-01-05', 100.12, '1234', '2020-09-01');
> insert into transactions(ccnum, date, amount, cvv, exp) values ('4444123456789012', '2019-01-07', 2400.18, '5544', '2021-02-01');
> insert into transactions(ccnum, date, amount, cvv, exp) values ('4465122334455667', '2019-01-29', 1450.87, '9876', '2020-06-01');
> go
```

## References

[Microsoft SQL Server DockerHub](https://hub.docker.com/_/microsoft-mssql-server)
