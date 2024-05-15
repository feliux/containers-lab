package main

import (
	"context"
	"flag"
	"fmt"
	"path/filepath"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

var (
	auth           string
	namespace      string
	deploymentName string
	changeCause    string
	kubeconfig     *string
)

func init() {
	flag.StringVar(&auth, "auth", "", "Specify auth method based on RBAC (inside a pod) or kubeconfig (outside the cluster). Possible values are inside or outside.")
	flag.StringVar(&namespace, "namespace", "", "K8s namespace.")
	flag.StringVar(&deploymentName, "deployment-name", "", "Deployment name to rollout.")
	flag.StringVar(&changeCause, "change-cause", "cronjob execution", "Change cause for annotation kubernetes.io/change-cause.")
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) Absolute path to the kubeconfig file.")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "Absolute path to the kubeconfig file.")
	}
	flag.Parse()
}

func Auth() (*rest.Config, error) {
	switch auth {
	case "inside":
		// create the in-cluster config
		config, err := rest.InClusterConfig()
		return config, err
	case "outside":
		// create the out-cluster config
		config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
		return config, err
	default:
		panic("You have to include auth flag. Possible values are inside or outside.")
	}
}

func main() {
	config, err := Auth()
	if err != nil {
		panic(err.Error())
	}
	// creates the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err)
	}
	// set the namespace
	deploymentsClient := clientset.AppsV1().Deployments(namespace)
	fmt.Printf("Listing deployments in namespace %q:\n", namespace)
	list, err := deploymentsClient.List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		panic(err)
	}
	// list deployment information
	for _, d := range list.Items {
		fmt.Printf(" * %s (%d replicas)\n", d.Name, *d.Spec.Replicas)
	}
	// set the annotation and restart
	data := fmt.Sprintf(`{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt":"%s","kubernetes.io/change-cause":"%s"}}}}}`, time.Now().String(), changeCause)
	_, err = deploymentsClient.Patch(context.Background(), deploymentName, types.StrategicMergePatchType, []byte(data), metav1.PatchOptions{FieldManager: "kubectl-rollout"})
	if err != nil {
		panic(err)
	}
	fmt.Printf("Rollout for deployment %s succeeded. Check running: kubectl rollout history deployment/<deployment-name>\n", deploymentName)
}
