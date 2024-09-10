-- name: create-walk-table
CREATE TABLE IF NOT EXISTS walk(
	distance INT,
	duration INT)
WITH ( 
	connector = 'datagen',
	fields.distance.kind = 'sequence',
	fields.distance.start = '1',
	fields.distance.end  = '60',
	fields.duration.kind = 'sequence',
	fields.duration.start = '1',
	fields.duration.end = '60',
	datagen.rows.per.second='15',
	datagen.split.num = '1'
) FORMAT PLAIN ENCODE JSON

-- name: create-mv-counter
CREATE MATERIALIZED VIEW IF NOT EXISTS counter AS 
    SELECT
		SUM(distance) as total_distance,
		SUM(duration) as total_duration
	FROM walk

-- name: select-all-counter
SELECT * FROM counter
