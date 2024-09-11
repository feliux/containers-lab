package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
	"github.com/aws/aws-sdk-go/aws"
)

// AWSConfig encapsulates the AWS configuration.
type AWSConfig struct {
	AKID, SCK, TKN string
	KinesisConfig  KinesisConfig
}

// KinesisConfig encapsulates the Kinesis configuration.
type KinesisConfig struct {
	StreamName, PartitionKey, Region, Endpoint string
	Client                                     *kinesis.Client
}

// Data represents a custom data to send to Kinesis.
type Data struct {
	Timestamp                    int64 //time.Time
	DateDataPart                 string
	TenantID, ClientID, Resource string
}

// Task represents a task pending to do.
type Task struct {
	ID int
	b  []byte
}

var (
	numTasks   int = 1000
	numWorkers int = 500

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

// worker is a logic construction for doing tasks.
func worker(id int, tasks <-chan Task, results chan<- Task, wg *sync.WaitGroup, kinesisConfig KinesisConfig) {
	defer wg.Done()
	for task := range tasks {
		// fmt.Printf("Worker %d processing task %d\n", id, task.ID)
		err := Put(task.b, kinesisConfig)
		if err != nil {
			log.Fatalf("Failed to put record, %v", err)
		}
		results <- task // Sending back the processed task to results channel
	}
}

// NewKinesisClient load the AWS configuration for establishing a connection to AWS Kinesis service.
func NewKinesisClient(awsConfig AWSConfig) *kinesis.Client {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(awsConfig.KinesisConfig.Region),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(awsConfig.AKID, awsConfig.SCK, awsConfig.TKN)),
	)
	if err != nil {
		log.Fatalf("Failed to create AWS session, %v", err)
	}

	// Create Kinesis client
	return kinesis.NewFromConfig(cfg, func(o *kinesis.Options) {
		o.BaseEndpoint = aws.String(awsConfig.KinesisConfig.Endpoint)
	})

}

// Put creates a record request and send it to a Kinesis stream.
func Put(b []byte, kinesisConfig KinesisConfig) error {
	// Create a PutRecord request
	input := &kinesis.PutRecordInput{
		Data:         b,
		StreamName:   aws.String(kinesisConfig.StreamName),
		PartitionKey: aws.String(kinesisConfig.PartitionKey),
	}

	// Send the data to the stream
	// result, err := kinesisConfig.Client.PutRecord(context.TODO(), input)
	_, err := kinesisConfig.Client.PutRecord(context.TODO(), input)
	if err != nil {
		return err
	}
	// fmt.Printf("Successfully put record to stream, shard ID: %s, sequence number: %s\n", *result.ShardId, *result.SequenceNumber)
	return nil
}

func main() {
	jsonB, err := json.Marshal(customData)
	if err != nil {
		log.Fatalf("Failed marshalling data to json: %v", err)
	}
	tasks := make(chan Task, numTasks)
	results := make(chan Task, numTasks)
	awsConfig.KinesisConfig.Client = NewKinesisClient(awsConfig)
	var wg sync.WaitGroup
	// Create workers
	for i := 1; i <= numWorkers; i++ {
		wg.Add(1)
		go worker(i, tasks, results, &wg, awsConfig.KinesisConfig)
	}
	t0 := time.Now()
	// Add tasks to the tasks channel
	for i := 1; i <= numTasks; i++ {
		tasks <- Task{
			ID: i,
			b:  jsonB,
		}
	}
	close(tasks) // Close tasks channel to indicate no more tasks
	wg.Wait()
	close(results) // Close results channel after all workers are done
	// for result := range results {
	// 	fmt.Println("Processed:", result.ID)
	// }
	diff := time.Since(t0)
	fmt.Println(diff)
}
