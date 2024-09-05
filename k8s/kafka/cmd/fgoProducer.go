package main

import (
	"context"
	"fmt"
	"sync"

	"github.com/twmb/franz-go/pkg/kgo"
)

const topic string = "foo"

func main() {
	// tlsDialer := &tls.Dialer{NetDialer: &net.Dialer{Timeout: 1 * time.Second}, Config: &tls.Config{}}

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

	record := &kgo.Record{Topic: topic, Value: []byte("bar")}

	// Producer ASYNC
	// All record production goes through Produce, and the callback can be used
	// to allow for synchronous or asynchronous production.
	var wg sync.WaitGroup
	wg.Add(1)
	cl.Produce(ctx, record, func(_ *kgo.Record, err error) {
		defer wg.Done()
		if err != nil {
			fmt.Printf("record had a produce error: %v\n", err)
		}

	})
	wg.Wait()

	// Producer SYNC
	// if err := cl.ProduceSync(ctx, record).FirstErr(); err != nil {
	// 	fmt.Printf("record had a produce error while synchronously producing: %v\n", err)
	// }
}
