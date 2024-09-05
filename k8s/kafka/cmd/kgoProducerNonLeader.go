package main

// Can not set the topic and partition:
//
// Unknown Topic Or Partition: the request is for a topic or partition that does not exist on this broker

// func main() {
// 	// to connect to the kafka leader via an existing non-leader connection rather than using DialLeader
// 	conn, err := kafka.Dial("tcp", "localhost:9092")
// 	if err != nil {
// 		panic(err.Error())
// 	}
// 	defer conn.Close()
// 	controller, err := conn.Controller()
// 	if err != nil {
// 		panic(err.Error())
// 	}

// 	// k port-forward pod/my-release-kafka-controller-1 9093:9092
// 	// controller.Host = "localhost"
// 	// controller.Port = 9093

// 	var connLeader *kafka.Conn
// 	connLeader, err = kafka.Dial("tcp", net.JoinHostPort(controller.Host, strconv.Itoa(controller.Port)))
// 	if err != nil {
// 		panic(err.Error())
// 	}
// 	defer connLeader.Close()

// 	conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
// 	_, err = conn.WriteMessages(
// 		kafka.Message{Value: []byte("one!")},
// 		kafka.Message{Value: []byte("two!")},
// 		kafka.Message{Value: []byte("three!")},
// 	)
// 	if err != nil {
// 		log.Fatal("failed to write messages:", err)
// 	}

// 	if err := conn.Close(); err != nil {
// 		log.Fatal("failed to close writer:", err)
// 	}
// }
