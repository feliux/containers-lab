package main

import (
	"fmt"
	"log"

	"database/sql"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/qustavo/dotsql"
)

const (
	connStr string = "postgres://root@localhost:4567/dev"
	sqlFile string = "./sql/queries.sql"
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
	_, err = dot.Exec(db, "create-walk-table")
	if err != nil {
		log.Fatalf("Error executing create table: %v\n", err)
	}

	// View
	_, err = dot.Exec(db, "create-mv-counter")
	if err != nil {
		log.Fatalf("Error executing create mv: %v\n", err)
	}

	// Query
	var total_distance, total_duration float64
	row, err := dot.QueryRow(db, "select-all-counter")
	if err != nil {
		log.Fatalf("Error executing query data: %v\n", err)
	}
	row.Scan(&total_distance, &total_duration)
	fmt.Printf("Total Distance: %.2f, Total Duration: %.2f\n", total_distance, total_duration)
}
