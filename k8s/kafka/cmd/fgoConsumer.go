package main

import (
	"context"
	"fmt"

	"github.com/twmb/franz-go/pkg/kgo"
)

const topic string = "foo"

func main() {
	// tlsDialer := &tls.Dialer{NetDialer: &net.Dialer{Timeout: 2 * time.Second}, Config: &tls.Config{InsecureSkipVerify: true}}

	seeds := []string{"localhost:9092"}

	// SASL Plain credentials
	// user := "userX"
	// password := "changeme"

	opts := []kgo.Opt{
		kgo.SeedBrokers(seeds...),
		// SASL Options
		// kgo.SASL(plain.Auth{
		// 	User: user,
		// 	Pass: password,
		// }.AsMechanism()),

		// kgo.Dialer(tlsDialer.DialContext),
		kgo.ConsumeTopics(topic),
	}
	cl, err := kgo.NewClient(opts...)
	if err != nil {
		panic(err)
	}
	defer cl.Close()

	ctx := context.Background()

	// record := &kgo.Record{Topic: topic, Value: []byte("bar")}
	// 1.) Producing a message
	// All record production goes through Produce, and the callback can be used
	// to allow for synchronous or asynchronous production.
	// var wg sync.WaitGroup
	// wg.Add(1)
	// cl.Produce(ctx, record, func(_ *kgo.Record, err error) {
	// 	defer wg.Done()
	// 	if err != nil {
	// 		fmt.Printf("record had a produce error: %v\n", err)
	// 	}

	// })
	// wg.Wait()

	// if err := cl.ProduceSync(ctx, record).FirstErr(); err != nil {
	// 	fmt.Printf("record had a produce error while synchronously producing: %v\n", err)
	// }
	for {
		fetches := cl.PollFetches(ctx)
		if errs := fetches.Errors(); len(errs) > 0 {
			// All errors are retried internally when fetching, but non-retriable errors are
			// returned from polls so that users can notice and take action.
			panic(fmt.Sprint(errs))
		}

		// We can iterate through a record iterator...
		iter := fetches.RecordIter()
		for !iter.Done() {
			record := iter.Next()
			fmt.Println(string(record.Value), "from an iterator!")
		}

		// or a callback function.
		fetches.EachPartition(func(p kgo.FetchTopicPartition) {
			for _, record := range p.Records {
				fmt.Println(string(record.Value), "from range inside a callback!")
			}

			// We can even use a second callback!
			p.EachRecord(func(record *kgo.Record) {
				fmt.Println(string(record.Value), "from a second callback!")
			})
		})
	}
}
