// https://gist.github.com/mhowlett/e9491aad29817aeda6003c3404874b35
package main

import (
	"context"
	crand "crypto/rand"
	"flag"
	"fmt"
	"io"
	"log"
	"math/rand"
	"os"
	"strings"
	"time"

	"github.com/IBM/sarama"
	"github.com/confluentinc/confluent-kafka-go/kafka"
	kafkago "github.com/segmentio/kafka-go"
)

var (
	client string
	mode   string

	brokers   string
	topic     string
	partition int

	msgSize     int
	numMessages int

	value []byte
)

func newUUID() (string, error) {
	uuid := make([]byte, 16)
	n, err := io.ReadFull(crand.Reader, uuid)
	if n != len(uuid) || err != nil {
		return "", err
	}
	uuid[8] = uuid[8]&^0xc0 | 0x80
	uuid[6] = uuid[6]&^0xf0 | 0x40
	return fmt.Sprintf("%x-%x-%x-%x-%x", uuid[0:4], uuid[4:6], uuid[6:8], uuid[8:10], uuid[10:]), nil
}

func consumeConfluentKafkaGo() {

	// !poll -> ~150k/s
	// poll  -> ~170k/s
	var poll = true

	group, _ := newUUID()

	c, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers":               brokers,
		"group.id":                        group,
		"session.timeout.ms":              6000,
		"go.events.channel.enable":        !poll,
		"go.application.rebalance.enable": false,
		"enable.auto.commit":              false,
		"default.topic.config":            kafka.ConfigMap{"auto.offset.reset": "earliest"},
	})

	if err != nil {
		log.Printf("could not set up kafka consumer: %s", err.Error())
		os.Exit(1)
	}

	c.Assign([]kafka.TopicPartition{kafka.TopicPartition{Topic: &topic, Partition: int32(partition), Offset: 0}})

	var start = time.Now()

	if poll {
		var msgCount = 0
		for msgCount < numMessages {
			ev := c.Poll(100)
			if ev == nil {
				continue
			}
			switch e := ev.(type) {
			case *kafka.Message:
				msgCount++
				break
			case kafka.PartitionEOF:
				fmt.Printf("%% Reached %v\n", e)
			case kafka.Error:
				fmt.Fprintf(os.Stderr, "%% Error: %v\n", e)
				os.Exit(1)
			default:
				fmt.Printf("Ignored %v\n", e)
				os.Exit(1)
			}
		}
	} else {
		var msgCount = 0
		for msgCount < numMessages {
			select {
			case ev := <-c.Events():
				switch e := ev.(type) {
				case *kafka.Message:
					msgCount++
					break
				case kafka.PartitionEOF:
					log.Printf("%% Reached %v\n", e)
					os.Exit(1)
				case kafka.Error:
					log.Printf("%% Error: %v\n", e)
					os.Exit(1)
				}
			}
		}
	}

	elapsed := time.Since(start)

	log.Printf("[conflunet-kafka-go consumer] msg/s: %f", (float64(numMessages) / elapsed.Seconds()))
}

func produceConfluentKafkaGo() {

	// ~380k/s

	var p, err = kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": brokers, "linger.ms": 100})
	if err != nil {
		log.Printf("could not set up kafka producer: %s", err.Error())
		os.Exit(1)
	}

	done := make(chan bool)
	go func() {
		var msgCount int
		for e := range p.Events() {
			msg := e.(*kafka.Message)
			if msg.TopicPartition.Error != nil {
				log.Printf("delivery report error: %v", msg.TopicPartition.Error)
				os.Exit(1)
			}
			msgCount++
			if msgCount >= numMessages {
				done <- true
			}
		}
	}()

	defer p.Close()

	var start = time.Now()
	for j := 0; j < numMessages; j++ {
		p.ProduceChannel() <- &kafka.Message{TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: int32(partition)}, Value: value}
	}
	<-done
	elapsed := time.Since(start)

	log.Printf("[confluent-kafka-go producer] msg/s: %f", (float64(numMessages) / elapsed.Seconds()))
}

func consumeSarama() {

	// ~1.1M/s

	config := sarama.NewConfig()
	config.Version = sarama.V1_0_0_0
	config.Consumer.Return.Errors = true
	brokers := []string{brokers}

	// Create new consumer
	master, err := sarama.NewConsumer(brokers, config)
	if err != nil {
		panic(err)
	}

	defer master.Close()

	consumer, err := master.ConsumePartition(topic, 0, sarama.OffsetOldest)
	if err != nil {
		panic(err)
	}

	msgCount := 0

	var start = time.Now()
	doneCh := make(chan bool)
	go func() {
		for {
			select {
			case err := <-consumer.Errors():
				fmt.Println(err)
			case <-consumer.Messages():
				// per-partition errors?
				msgCount++
				if msgCount >= numMessages {
					doneCh <- true
				}
			}
		}
	}()
	<-doneCh
	elapsed := time.Since(start)

	log.Printf("[sarama consumer] msg/s: %f", (float64(numMessages) / elapsed.Seconds()))
}

func produceSarama() {

	// ~410k/s

	conf := sarama.NewConfig()
	conf.Version = sarama.V1_0_0_0
	conf.Producer.Return.Successes = true
	conf.Producer.Flush.Frequency = time.Duration(100) * time.Millisecond
	// the default 1000000 results in request-too-large errors.
	sarama.MaxRequestSize = 999000

	var p, err = sarama.NewAsyncProducer(strings.Split(brokers, ","), conf)
	if err != nil {
		log.Printf("could not set up kafka producer: %s", err.Error())
		os.Exit(1)
	}

	done := make(chan bool)
	go func() {
		var nomessages int
		for _ = range p.Successes() {
			nomessages++
			if nomessages%numMessages == 0 {
				done <- true
			}
		}
	}()

	go func() {
		for err := range p.Errors() {
			log.Printf("failed to deliver message: %s", err.Error())
			os.Exit(1)
		}
	}()

	defer func() {
		err := p.Close()
		if err != nil {
			log.Printf("failed to close producer: %s", err.Error())
			os.Exit(1)
		}
	}()

	var start = time.Now()
	for j := 0; j < numMessages; j++ {
		p.Input() <- &sarama.ProducerMessage{Topic: topic, Partition: int32(partition), Value: sarama.ByteEncoder(value)}
	}
	<-done
	elapsed := time.Since(start)

	log.Printf("[sarama producer] msg/s: %f", (float64(numMessages) / elapsed.Seconds()))
}

func produceKafkaGo() {

	// this apparently produces synchronously and is very slow - is there a way to
	// produce synchronously.
	// w := kafkago.NewWriter(kafkago.WriterConfig{
	// 	Brokers: []string{brokers},
	// 	Topic:   topic,
	// 	// match other clients:
	// 	Balancer:     &kafkago.Hash{},
	// 	BatchTimeout: time.Duration(100) * time.Millisecond,
	// 	// these are low by default on this client
	// 	QueueCapacity: 10000,
	// 	BatchSize:     1000000,
	// })

	// https://gist.github.com/mhowlett/e9491aad29817aeda6003c3404874b35?permalink_comment_id=3699569#gistcomment-3699569
	w := &kafkago.Writer{
		Addr:         kafkago.TCP([]string{brokers}[0]),
		Balancer:     &kafkago.Hash{},
		Topic:        topic,
		BatchTimeout: time.Duration(100) * time.Millisecond,
		RequiredAcks: kafkago.RequiredAcks(0),
		BatchSize:    1000000,
		Async:        true,
	}

	var start = time.Now()
	for j := 0; j < numMessages; j++ {
		err := w.WriteMessages(context.Background(), kafkago.Message{Value: value})
		if err != nil {
			log.Printf("failed to write message: %s", err)
			os.Exit(1)
		}
	}
	elapsed := time.Since(start)

	w.Close()

	log.Printf("[kafka-go] msg/s: %f", (float64(numMessages) / elapsed.Seconds()))
}

func main() {

	flag.StringVar(&brokers, "brokers", "localhost:9092", "broker addresses")
	flag.StringVar(&topic, "topic", "foo", "topic")
	flag.IntVar(&partition, "partition", 0, "partition")
	flag.IntVar(&msgSize, "msgsize", 64, "message size")
	flag.IntVar(&numMessages, "numMessages", 10000000, "number of messages")
	flag.StringVar(&client, "client", "confluent-kafka-go", "confluent-kafka-go / sarama / kafka-go")
	flag.StringVar(&mode, "mode", "producer", "producer / consumer")
	flag.Parse()

	value = make([]byte, msgSize)
	rand.Read(value)

	switch client {

	case "confluent-kafka-go":
		if mode == "producer" {
			produceConfluentKafkaGo()
		} else {
			consumeConfluentKafkaGo()
		}
		break

	case "sarama":
		if mode == "producer" {
			produceSarama()
		} else {
			consumeSarama()
		}
		break

	case "kafka-go":
		if mode == "producer" {
			produceKafkaGo()
		} else {
			log.Printf("not implemented")
			os.Exit(1)
		}
		break

	default:
		log.Printf("unknown client: %s", client)
	}
}
