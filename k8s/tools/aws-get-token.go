package main

import (
	"fmt"
	"log"

	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
)

var (
	cluster_name string = ""
)

// https://aws.github.io/aws-eks-best-practices/security/docs/iam/
func main() {
	g, _ := token.NewGenerator(false, false)
	tk, err := g.Get(cluster_name)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(tk)
}
