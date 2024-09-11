package main

import (
	"context"
	"log"

	"github.com/jackc/pgx/v5"
)

// const connStrt string = "postgres://USER:PASSWORD@localhost:4567/DATABASE"
const connStr string = "postgres://root@localhost:4567/dev"

var sql string

func main() {
	conn, err := pgx.Connect(context.Background(), connStr)
	defer conn.Close(context.Background())
	if err != nil {
		log.Fatalf("Unable to connect to RisingWave: %v\n", err)
	}
	log.Println("Connected to RisingWave")

	// Source
	sql = `CREATE TABLE walk(distance INT, duration INT)
        WITH ( 
            connector = 'datagen',
            fields.distance.kind = 'sequence',
            fields.distance.start = '1',
            fields.distance.end  = '60',
            fields.duration.kind = 'sequence',
            fields.duration.start = '1',
            fields.duration.end = '30',
            datagen.rows.per.second='15',
            datagen.split.num = '1'
        ) FORMAT PLAIN ENCODE JSON`

	_, err = conn.Exec(context.Background(), sql)
	if err != nil {
		log.Fatalf("Error executing create table: %v\n", err)
	}

	// View
	sql = `CREATE MATERIALIZED VIEW counter AS 
        SELECT
            SUM(distance) as total_distance,
            SUM(duration) as total_duration
        FROM walk`

	_, err = conn.Exec(context.Background(), sql)
	if err != nil {
		log.Fatalf("Error executing create mv: %v\n", err)
	}

	// Query
	sql = `SELECT * FROM counter`
	rows, err := conn.Query(context.Background(), sql)
	defer rows.Close()
	if err != nil {
		log.Fatalf("Error executing query data: %v\n", err)
	}
	for rows.Next() {
		var total_distance, total_duration float64
		err = rows.Scan(&total_distance, &total_duration)
		if err != nil {
			log.Fatalf("Error executing scan: %v\n", err)
		}
		log.Printf("Total Distance: %.2f, Total Duration: %.2f\n", total_distance, total_duration)
	}
	// return rows.Err()
}
