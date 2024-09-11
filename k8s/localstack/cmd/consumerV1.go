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
	StreamName, Region, Endpoint string
}

var (
	awsConfig AWSConfig = AWSConfig{
		AKID: "AKID",
		SCK:  "SECRET_KEY",
		TKN:  "TOKEN",
		KinesisConfig: KinesisConfig{
			StreamName: "my-kinesis-stream",
			Region:     "us-east-1",
			Endpoint:   "http://192.168.1.100:31566",
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

	// Get shard iterator
	shardIterator, err := getShardIterator(svc, awsConfig.KinesisConfig.StreamName)
	if err != nil {
		log.Fatalf("Failed to get shard iterator, %v", err)
	}

	// Read records from the shard
	for {
		input := &kinesis.GetRecordsInput{
			ShardIterator: shardIterator,
		}

		output, err := svc.GetRecords(input)
		if err != nil {
			log.Fatalf("Failed to get records, %v", err)
		}

		for _, record := range output.Records {
			fmt.Printf("Record: %s\n", string(record.Data))
		}
		// The shard iterator is updated to point to the next set of records. The loop breaks when there are no more records to read.
		shardIterator = output.NextShardIterator
		if shardIterator == nil {
			break
		}
	}
}

// getShardIterator retrieves a shard iterator for the stream. The shard iterator points to the location in the shard from where records can be read.
func getShardIterator(svc *kinesis.Kinesis, streamName string) (*string, error) {
	input := &kinesis.DescribeStreamInput{
		StreamName: aws.String(streamName),
	}

	result, err := svc.DescribeStream(input)
	if err != nil {
		return nil, err
	}

	shardID := result.StreamDescription.Shards[0].ShardId

	iterInput := &kinesis.GetShardIteratorInput{
		StreamName:        aws.String(streamName),
		ShardId:           shardID,
		ShardIteratorType: aws.String("TRIM_HORIZON"),
	}

	iterResult, err := svc.GetShardIterator(iterInput)
	if err != nil {
		return nil, err
	}

	return iterResult.ShardIterator, nil
}
