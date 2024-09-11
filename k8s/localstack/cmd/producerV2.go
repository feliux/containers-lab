package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
)

// AWSConfig encapsulates the AWS configuration.
type AWSConfig struct {
	AKID, SCK, TKN string
	KinesisConfig  KinesisConfig
}

// KinesisConfig encapsulates the Kinesis configuration.
type KinesisConfig struct {
	StreamName, Region, Endpoint, PartitionKey string
}

type Data struct {
	Timestamp                    int64 //time.Time
	DateDataPart                 string
	TenantID, ClientID, Resource string
}

var (
	awsConfig AWSConfig = AWSConfig{
		AKID: "AKID",
		SCK:  "SECRET_KEY",
		TKN:  "TOKEN",
		KinesisConfig: KinesisConfig{
			StreamName:   "my-kinesis-stream",
			PartitionKey: "partitionKey-1",
			Region:       "us-east-1",
			Endpoint:     "http://192.168.1.100:31566",
		},
	}
	customData Data = Data{
		// Timestamp:    time.Unix(1e9, 0).UTC(),
		Timestamp:    time.Now().UnixNano(),
		DateDataPart: time.Now().Format("2006-02-01"),
		TenantID:     "foo",
		ClientID:     "bar",
		Resource:     "/baz",
	}
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(awsConfig.KinesisConfig.Region),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(awsConfig.AKID, awsConfig.SCK, awsConfig.TKN)),
	)
	if err != nil {
		log.Fatalf("Failed to create session, %v", err)
	}

	// Create Kinesis client
	svc := kinesis.NewFromConfig(cfg, func(o *kinesis.Options) {
		o.BaseEndpoint = aws.String(awsConfig.KinesisConfig.Endpoint)
	})

	// Prepare the data to send
	// data := []byte("example data from v2")
	b, err := json.Marshal(customData)
	// b, err := os.ReadFile("./data/test.json")
	if err != nil {
		log.Fatalf("Failed marshalling data to json: %v", err)
	}

	// Create a PutRecord request
	input := &kinesis.PutRecordInput{
		Data:         b,
		StreamName:   aws.String(awsConfig.KinesisConfig.StreamName),
		PartitionKey: aws.String(awsConfig.KinesisConfig.PartitionKey),
	}

	// Send the data to the stream
	result, err := svc.PutRecord(context.TODO(), input)
	if err != nil {
		log.Fatalf("Failed to put record, %v", err)
	}

	fmt.Printf("Successfully put record to stream, shard ID: %s, sequence number: %s\n", *result.ShardId, *result.SequenceNumber)
}
