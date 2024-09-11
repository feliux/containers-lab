package main

import (
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
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
)

func main() {
	// Create a new session using the default AWS profile
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(awsConfig.KinesisConfig.Region),
		Credentials: credentials.NewStaticCredentials(awsConfig.AKID, awsConfig.SCK, awsConfig.TKN),
		Endpoint:    aws.String(awsConfig.KinesisConfig.Endpoint),
	})
	if err != nil {
		log.Fatalf("Failed to create session, %v", err)
	}

	// Create Kinesis client
	svc := kinesis.New(sess)

	// Prepare the data to send
	data := []byte("example data from v1")

	// Create a PutRecord request
	input := &kinesis.PutRecordInput{
		Data:         data,
		StreamName:   aws.String(awsConfig.KinesisConfig.StreamName),
		PartitionKey: aws.String(awsConfig.KinesisConfig.PartitionKey),
	}

	// Send the data to the stream
	result, err := svc.PutRecord(input)
	if err != nil {
		log.Fatalf("Failed to put record, %v", err)
	}

	fmt.Printf("Successfully put record to stream, shard ID: %s, sequence number: %s\n", *result.ShardId, *result.SequenceNumber)
}
