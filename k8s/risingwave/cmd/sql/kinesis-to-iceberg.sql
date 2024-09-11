-- CREATE {TABLE | SOURCE} IF NOT EXISTS my_kinesis_table (
-- name: create-kinesis-source
CREATE TABLE IF NOT EXISTS my_kinesis_table (
	Timestamp bigint,
	DateDataPart date,
	TenantID varchar,
	ClientID varchar,
	Resource varchar,
)
WITH (
	connector = 'kinesis',
	stream = 'my-kinesis-stream',
	aws.region = 'us-east-1',
	endpoint = 'http://localstack.localstack.svc.cluster.local:4566',
--    endpoint = '192.168.1.100:31566',
--    aws.credentials.session_token='AQoEXAMPLEH4aoAH0gNCAPyJxz4BlCFFxWNE1OPTgk5TthT+FvwqnKwRcOIfrRh3c/L To6UDdyJwOOvEVPvLXCrrrUtdnniCEXAMPLE/IvU1dYUg2RVAJBanLiHb4IgRmpRV3z rkuWJOgQs8IZZaIv2BXIa2R4OlgkBN9bkUDNCJiBeb/AXlzBBko7b15fjrBs2+cTQtp Z3CYWFXG8C5zqx37wnOE49mRl/+OtkIKGO7fAE',
--    aws.credentials.role.arn='arn:aws-cn:iam::602389639824:role/demo_role',
--    aws.credentials.role.external_id='demo_external_id',
	aws.credentials.access_key_id = 'AKID',
	aws.credentials.secret_access_key = 'SECRET_KEY',
	scan.startup.mode = 'latest'
) FORMAT PLAIN ENCODE JSON;

-- https://docs.risingwave.com/docs/current/sink-to-iceberg/
-- name: create-iceberg-sink
CREATE SINK iceberg_sink FROM my_kinesis_table
WITH (
    connector = 'iceberg',
	type = 'append-only',
	force_append_only = 'true',
    s3.endpoint = 'http://192.168.1.100:9000',
	s3.region = 'us-east-1',
    s3.access.key = 'admin',
    s3.secret.key = 'password',
	catalog.type = 'rest',
	catalog.name = 'rest_backend',
	catalog.uri = 'http://192.168.1.100:8181',
    database.name = 'dev',
    table.name = 'my_kinesis_table',
    -- primary_key = 'seq_id',
    warehouse.path = 's3a://warehouse',
	-- commit_checkpoint_interval = ''
);
