package main

import (
	"log"

	"database/sql"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/qustavo/dotsql"
)

const (
	connStr string = "postgres://root@localhost:4567/dev"
	sqlFile string = "./sql/kinesis-to-iceberg.sql"
)

func main() {
	db, err := sql.Open("pgx", connStr)
	if err != nil {
		log.Fatalf("Unable to connect to RisingWave: %v\n", err)
	}
	log.Println("Connected to RisingWave")

	dot, err := dotsql.LoadFromFile(sqlFile)
	if err != nil {
		log.Fatalf("Error loading sql: %v\n", err)
	}
	// Source
	_, err = dot.Exec(db, "create-kinesis-source")
	if err != nil {
		log.Fatalf("Error executing create table: %v\n", err)
	}

	// Sink
	_, err = dot.Exec(db, "create-iceberg-sink")
	if err != nil {
		log.Fatalf("Error executing create sink: %v\n", err)
	}
}
