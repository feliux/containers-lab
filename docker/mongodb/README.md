# Mongodb

Set up a MongDB server.

## Deployment

Deploy services running the following command `$ docker-compose up -d`. Destroy with `$ docker-compose down -v`.

## Usage

**Connect to ddbb**

```sh
# Connect
$ mongosh -u admin -p changeme --authenticationDatabase admin localhost:27017/myddbb
$ mongosh -u admin -p changeme --host localhost --authenticationDatabase admin myddbb
$ mongosh -u admin --authenticationDatabase admin mongodb://root@localhost:27017/myddbb
# View ddbb
$ show dbs
# Populate some data
$ db.transactions.insert([
{
    "ccnum" : "4444333322221111",
    "date" : "2019-01-05",
    "amount" : 100.12,
    "cvv" : "1234",
    "exp" : "09/2020"
},
{
    "ccnum" : "4444123456789012",
    "date" : "2019-01-07",
    "amount" : 2400.18,
    "cvv" : "5544",
    "exp" : "02/2021"
},
{
    "ccnum" : "4465122334455667",
    "date" : "2019-01-29",
    "amount" : 1450.87,
    "cvv" : "9876",
    "exp" : "06/2020"
}
]);
# Show tables/collections
$ show collections
```

## References

[Mongo DockerHub](https://hub.docker.com/_/mongo)
