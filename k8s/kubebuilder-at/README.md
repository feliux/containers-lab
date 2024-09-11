# Kubebuilder

here you will experience what it's like to create and run a Kubernetes Operator that manages a custom resource. The Operator is created using the Kubebuilder tool. The custom resources will be called Ats.

Kubebuilder was released as open source in August from 2018. Two technical staff members from Google, Phillip Wittrock and Sunil Arora, founded the project. Kubebuilder is now a Kubernetes special interest group (SIG) under Apache License 2.0.

The Operator pattern is an important technique to extend and build upon the basic features of Kubernetes. Operators are controllers with roles that observe and manage associated CRDs. There are a variety of projects that provide tools to build Operators. Kubebuilder is one prominent technique.

This lab stands on the shoulders of others. The at utility is found on many operating systems, and it allows you to schedule a command to run at a future date. There is a project called cnat and it stands for cloud native at. There is also an outdated tutorial on Kubebuilder with cnat. Many improvements were applied to Kubebuilder which deprecated that tutorial. Ken Sipe created an updated lab inspired by at, cnat, and the old tutorial. In turn, this lab is a translation of Ken's lab. You now get to enjoy the broad shoulders of open source and the cloud native community.

Here, you will learn how to:

- Modify, build, and test code in a Kubebuilder skeleton project
- Create a new CRD named At using Go structs and automation
- Define RBACs created through generations from code annotations
- Create a controller for observing and managing the at custom resources
- Associate Kubernetes events back to the managed resources

While this lab focuses on writing a Kubernetes Operator, its topic for demonstration is the old and trustworthy at command.

```bash
$ apt install at --yes -qq
$ whatis at
$ at -V
$ at -M -v -f at-example.txt 'now + 1 minute'
$ watch cat /tmp/at-example-result.txt
```

```bash
# Install kubebuilder
$ version=v3.3.0
$ os=$(go env GOOS)
$ arch=$(go env GOARCH)
$ curl -L -o kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/${version}/kubebuilder_${os}_${arch}
$ chmod +x kubebuilder && mv kubebuilder /usr/local/bin/
$ kubebuilder version
$ go version
```

**Initialize Kuberbuilder Project**

```bash
# Create a project directory
$ mkdir -p $GOPATH/src/example; cd $GOPATH/src/example
# Create a local directory populated with the skeleton to start writing and building your Operator
$ kubebuilder init --domain example.com
# Run the create command to create a new API (group/version) as cnat/v1alpha1 and the new Kind (CRD) At associated with the API
$ kubebuilder create api \
    --group cnat \
    --version v1alpha1 \
    --controller \
    --resource \
    --kind At

$ kubectl get crds
```

Open the `example/api/v1alpha1/at_types.go` file in the editor.

In this step, we will change the Spec and Status for the CRD. This requires changes to `AtSpec` struct and `AtStatus` struct respectively.

For the `AtSpec` struct, add `Schedule` and `Command`, both as strings. Here is the new `AtSpec` to replace the existing one.

```go
// AtSpec defines the desired state of At
type AtSpec struct {
  Schedule string `json:"schedule,omitempty"`
  Command string `json:"command,omitempty"`
}
```

Just below, for the `AtStatus` struct, replace the struct with this struct that has the added string variable named `Phase`.

```go
// AtStatus defines the observed state of At
type AtStatus struct {
  Phase string `json:"phase,omitempty"`
}
```

To complete the types definition, and for controller convenience, define the following phases in the same `example/api/v1alpha1/at_types.go` file just below the `AtStatus` struct.

```go
const (
  PhasePending = "PENDING"
  PhaseRunning = "RUNNING"
  PhaseDone    = "DONE"
)
```

Then build and apply the changes.

```bash
# With these modifications, build and generate files in the config folder.
$ make manifests
# With the updated manifests, apply the CRDs to your running Kubernetes cluster
$ make install
# With these updates, ensure the CRD for the At resource controller has been applied
$ kubectl get crds
$ kubectl describe crd ats
```

**Create Resource from Definition**

Create a custom resource based on this new At CRD. Create a new file called `example/at-sample.yaml` and open it in the editor. It will be blank. Add the following declaration to the opened YAML file in the editor.

```yaml
apiVersion: cnat.example.com/v1alpha1
kind: At
metadata:
  name: at-sample
spec:
  schedule: "2020-01-30T10:02:00Z"
  command: 'echo "Something from the past told me to do this now."'
```

```bash
$ kubectl apply -f at-sample.yaml
$ kubectl get at
```

**Add Printer Column for Phase**

Since the At process progresses through a few phases over time, it would be helpful to see its phase state when inspecting the objects. Add a printer column for the `Phase` status. In the `example/api/v1alpha1/at_types.go` file, replace the At struct so is has the added Kubebuilder markers (as comments) placed above the At struct block.

```go
//+kubebuilder:object:root=true
//+kubebuilder:subresource:status
//+kubebuilder:printcolumn:JSONPath=".spec.schedule", name=Schedule, type=string
//+kubebuilder:printcolumn:JSONPath=".status.phase", name=Phase, type=string
// At is the Schema for the ats API
type At struct {
  metav1.TypeMeta   `json:",inline"`
  metav1.ObjectMeta `json:"metadata,omitempty"`

  Spec   AtSpec   `json:"spec,omitempty"`
  Status AtStatus `json:"status,omitempty"`
}
```

With this change, run your controller so it serves the information for the Phase column. Run the controller.

```bash
$ cd /opt/go/src/example && make run
# Once you see the debug INFO line Starting workers, then the controller is ready.

# Reapply the CRDs to your running Kubernetes cluster
$ make install
$ kubectl get ats | grep -z PHASE
```

## Controller

Now that we have a CRD to work with, this step focuses on the controller to manage these At resources. Open `example/controllers/at_controller.go`. There are Kuberbuilder markers that define the access control (RBAC) for the CRD, however, this controller will need permission for Pods as well.

We will be adding some code to replace the whole import block at the top to support the additional code.

**Add Imports**

```go
import (
  // Core GoLang contexts
  "context"

  // 3rd party and SIG contexts
  "github.com/go-logr/logr"
  "k8s.io/apimachinery/pkg/api/errors"
  "k8s.io/apimachinery/pkg/runtime"
  "sigs.k8s.io/controller-runtime/pkg/client"
  "sigs.k8s.io/controller-runtime/pkg/reconcile"
  ctrl "sigs.k8s.io/controller-runtime"

  // Local Operator contexts
  cnatv1alpha1 "example/api/v1alpha1"
)
```

**Add New Logger**

Right after the imports is the `AtReconciler` struct. Add the Log `logr.Logger` definition to the struct.

```go
// AtReconciler reconciles an At object
type AtReconciler struct {
  client.Client
  Scheme *runtime.Scheme
  Log logr.Logger
}
```

This the Log defined, initialize it in the main.go. Where this struct is initialized in the `example/main.go` file near line 81, add the `Log` line.

```go
  if err = (&controllers.AtReconciler {
    Client:   mgr.GetClient(),
    Scheme:   mgr.GetScheme(),
    Log:      ctrl.Log.WithName("controllers").WithName("At"),
  }).SetupWithManager(mgr); err != nil {
    setupLog.Error(err, "unable to create controller", "controller", "At")
    os.Exit(1)
  }
```

**Add Markers**

Back in the file `example/controllers/at_controller.go`, just above the `func ... Reconcile ...` function, find these markers.

```go
//+kubebuilder:rbac:groups=cnat.example.com,resources=ats,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=cnat.example.com,resources=ats/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=cnat.example.com,resources=ats/finalizers,verbs=update
```

Right after those markers add these two new markers to give the controller Pod management permission.

```go
//+kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=apps,resources=deployments/status,verbs=get;update;patch
```

**Change Logger**

Continuing with updating the code inside the Reconcile function, change this first line with the log command from this.

```go
_ = log.FromContext(ctx)
```

to a specific logger name with some defined structure as follows.

```go
  logger := r.Log.WithValues("namespace", req.NamespacedName, "at", req.Name)
  logger.Info("== Reconciling At")
```

**Fetching At Instance**

Following these logger lines, where it comments `your logic here` add this code block to fetching instances of the CR for At.

```go
  // Fetch the At instance
  instance := &cnatv1alpha1.At{}
  err := r.Get(context.TODO(), req.NamespacedName, instance)
  if err != nil {
    if errors.IsNotFound(err) {
      // Request object not found, could have been deleted after reconcile request - return and don't requeue:
      return reconcile.Result{}, nil
    }
    // Error reading the object - requeue the request:
    return reconcile.Result{}, err
  }
```

**Check Phase Value**

Now that we have an instance defined by the request `NamespacedName`, add this block logic right after the previous insertion in the Reconcile function.

```go
  // If no phase set, default to pending (the initial phase):
  if instance.Status.Phase == "" {
    instance.Status.Phase = cnatv1alpha1.PhasePending
  }
```

This will check to see if the Phase has a status, and if not, it will be initialized

**Update Status**

Finish the Reconcile function with an update to the resource status just prior to the last return statement.

```go
  // Update the At instance, setting the status to the respective phase:
  err = r.Status().Update(context.TODO(), instance)
  if err != nil {
    return reconcile.Result{}, err
  }
```

**Test**

Start the new controller with your updates.

```bash
$ make run
$ kubectl get ats | grep -z PENDING
$ kubectl describe at at-sample | grep -z PENDING
$ kubectl get pods
```

## Controller Support Functions

Implement the controller details by adding two support functions and modifying another. These modifications will create the Pod and check the schedule. Open the `example/controllers/at_controller.go` file to edit the controller implementations.

**More Imports**

In this step, we will be adding some code to replace the whole import block at the top to support the additional code.

```go
import (
  "context"
  "fmt"
  "strings"
  "time"

  "github.com/go-logr/logr"
  corev1 "k8s.io/api/core/v1"
  "k8s.io/apimachinery/pkg/api/errors"
  metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
  "k8s.io/apimachinery/pkg/runtime"
  "k8s.io/apimachinery/pkg/types"
  ctrl "sigs.k8s.io/controller-runtime"
  "sigs.k8s.io/controller-runtime/pkg/client"
  "sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
  "sigs.k8s.io/controller-runtime/pkg/reconcile"

    cnatv1alpha1 "example/api/v1alpha1"
)
```

**Add Function newPodForCR**

Add the following function to the bottom of this same `at_controller.go` source file. The function will create new Pods per the resource specification.

```go
// newPodForCR returns a busybox Pod with same name/namespace declared in resource
func newPodForCR(cr *cnatv1alpha1.At) *corev1.Pod {
  labels := map[string]string {
    "app": cr.Name,
  }
  return &corev1.Pod {
    ObjectMeta: metav1.ObjectMeta {
      Name:      cr.Name + "-pod",
      Namespace: cr.Namespace,
      Labels:    labels,
    },
    Spec: corev1.PodSpec {
      Containers: []corev1.Container {{
        Name:    "busybox",
        Image:   "busybox",
        Command: strings.Split(cr.Spec.Command, " "),
      }},
      RestartPolicy: corev1.RestartPolicyOnFailure,
    },
  }
}
```

**Add Function timeUntilSchedule**

Add the following function to the bottom of this same `at_controller.go` source file. This function will calculate the scheduled time per the resource specification.

```go
// timeUntilSchedule parses the schedule string and returns the time until the schedule.
// When it is overdue, the duration is negative.
func timeUntilSchedule(schedule string) (time.Duration, error) {
  now := time.Now().UTC()
  layout := "2006-01-02T15:04:05Z"
  s, err := time.Parse(layout, schedule)
  if err != nil {
    return time.Duration(0), err
  }
  return s.Sub(now), nil
}
```

**Updates to the Reconcile Function**

Back in the `Reconcile` function, just after the block.

```go
if instance.Status.Phase == "" {
  instance.Status.Phase = cnatv1alpha1.PhasePending
}
```

Finish the same `Reconcile` function by inserting the following lengthy switch block.

```go
  // Make the main case distinction: implementing
  // the state diagram PENDING -> RUNNING -> DONE
  switch instance.Status.Phase {
    case cnatv1alpha1.PhasePending:
      logger.Info("Phase: PENDING")
      // As long as we haven't executed the command yet, we need to check if it's time already to act
      logger.Info("Checking schedule", "Target", instance.Spec.Schedule)
      // Check if it's already time to execute the command with a tolerance of 2 seconds:
      d, err := timeUntilSchedule(instance.Spec.Schedule)
      if err != nil {
        logger.Error(err, "Schedule parsing failure")
        // Error reading schedule. Wait until it is fixed.
        return reconcile.Result{}, err
      }
      logger.Info("Schedule parsing done", "Result", fmt.Sprintf("diff=%v", d))
      if d > 0 {
        // Not yet time to execute command, wait until the scheduled time
        return reconcile.Result{RequeueAfter: d}, nil
      }
      logger.Info("It's time!", "Ready to execute", instance.Spec.Command)
      instance.Status.Phase = cnatv1alpha1.PhaseRunning

    case cnatv1alpha1.PhaseRunning:
      logger.Info("Phase: RUNNING")
      pod := newPodForCR(instance)
      // Set At instance as the owner and controller
      if err := controllerutil.SetControllerReference(instance, pod, r.Scheme); err != nil {
        // requeue with error
        return reconcile.Result{}, err
      }
      found := &corev1.Pod{}
      err = r.Get(context.TODO(), types.NamespacedName{Name: pod.Name, Namespace: pod.Namespace}, found)
      // Try to see if the Pod already exists and if not
      // (which we expect) then create a one-shot Pod as per spec:
      if err != nil && errors.IsNotFound(err) {
        err = r.Create(context.TODO(), pod)
        if err != nil {
          // requeue with error
          return reconcile.Result{}, err
        }
        logger.Info("Pod launched", "name", pod.Name)
      } else if err != nil {
        // requeue with error
        return reconcile.Result{}, err
      } else if found.Status.Phase == corev1.PodFailed || found.Status.Phase == corev1.PodSucceeded {
        logger.Info("Container terminated", "reason", found.Status.Reason, "message", found.Status.Message)
        instance.Status.Phase = cnatv1alpha1.PhaseDone
      } else {
        // don't requeue because it will happen automatically when the Pod status changes
        return reconcile.Result{}, nil
      }

    case cnatv1alpha1.PhaseDone:
      logger.Info("Phase: DONE")
      return reconcile.Result{}, nil

    default:
      logger.Info("NOP")
      return reconcile.Result{}, nil
  }
```

**Test**

Start the new controller with your updates.

```bash
$ make run
$ kubectl get ats | grep -z PENDING
$ kubectl describe at at-sample | grep -z PENDING
$ kubectl get pods
```

## Watch Pods

We will modify the `SetupWithManager` function. Make an additional modification in `example/controllers/at_controller.go` to the existing `SetupWithManager` function. This modification will allow the controller to watch the Pods.

```go
func (r *AtReconciler) SetupWithManager(mgr ctrl.Manager) error {
  return ctrl.NewControllerManagedBy(mgr).
    For(&cnatv1alpha1.At{}).
    Owns(&cnatv1alpha1.At{}).
    Owns(&corev1.Pod{}).
    Complete(r)
}
```

Adding the `Owns(&corev1.Pod{})` line allows the Controller to have visibility into the Pod events.

**Test**

```bash
$ make run
$ kubectl get ats | grep -z PENDING
$ kubectl describe at at-sample | grep -z PENDING
$ kubectl get pods
```

The description is also reporting `DONE`. However, notice at the end, the Events reports `none`. You add some logic to update these event items next.

## Kubernetes Events

This step is extra credit for you. It explores how your Kubebuilder Operator can respond to Kubernetes events. Take a look at the description of the resource.

```bash
$ kubectl describe at at-sample | grep -z '<none>'
```

Notice in this description there are no event (`Events: <none>`) for this object. The next instructions enable the events listing.

**Controller Changes for Events**

Make the following modifications to the `example/controllers/at_controller.go` file.

**Add Import**

Add the Record context to the import list at the top.

```go
// imports
  "k8s.io/client-go/tools/record"
```

**Add EventRecorder**

Find the `AtReconciler` struct and add a `Recorder` line to the last line of the struct.

```go
// AtReconciler reconciles an At object
type AtReconciler struct {
  client.Client
  Log logr.Logger
  Scheme *runtime.Scheme
  Recorder record.EventRecorder
}
```

Now modify the `example/controllers/at_controller.go` code to record the events for each transition of the phase status. You will want to add each of these recording instructions to the respective cases in the switch statement you added earlier. Add each line just after the logging statement at the top of each case block.

For case `cnatv1alpha1.PhasePending`

```go
r.Recorder.Event(instance, "Pending", "PhaseChange", cnatv1alpha1.PhasePending)
```

For case `cnatv1alpha1.PhaseRunning`

```go
r.Recorder.Event(instance, "Running", "PhaseChange", cnatv1alpha1.PhaseRunning)
```

For case `cnatv1alpha1.PhaseDone`

```go
r.Recorder.Event(instance, "Done", "PhaseChange", cnatv1alpha1.PhaseDone)
```

**Main Change for Events**

Where this struct is initialized in the `example/main.go` file near line 81, add the `Recorder` line.

```go
  if err = (&controllers.AtReconciler {
    Client:   mgr.GetClient(),
    Scheme:   mgr.GetScheme(),
    Log:      ctrl.Log.WithName("controllers").WithName("At"),
    Recorder: mgr.GetEventRecorderFor("at-controller"),
  }).SetupWithManager(mgr); err != nil {
    setupLog.Error(err, "unable to create controller", "controller", "At")
    os.Exit(1)
  }
```

**Test**

With this new code, the describe command presents the list of Kubernetes events related to the resource.

```bash
$ make run
$ kubectl get ats | grep -z PENDING
$ kubectl describe at at-sample
# Now, these events are there. Also, the controller has successfully created two of the NGINX Pods that you asked it to create and manage in step 7
$ kubectl get pods
$ kubectl get pods | grep -z Completed
```

## Create a Fresh At Resource

With the controller complete, try creating a new resource and watch how the at function works. First, clear the previous At resource for clarity and to verify the controller will correctly clean up your pods.

```bash
# Delete the old At resource
$ kubectl delete at at-sample
$ kubectl get ats,pods
```

Create another custom resource with a better schedule. Open a `example/at-sample-two.yaml` file as before, add the following declaration to the opened YAML file in the editor.

```yaml
apiVersion: cnat.example.com/v1alpha1
kind: At
metadata:
  name: at-sample-two
spec:
  schedule: "date -d "$(date --utc +%FT%TZ) + 2 min" +%FT%TZ" # "paste date string here"
  command: 'echo "Happiness is when what you think, what you say, and what you do are in harmony."'
```

```bash
$ kubectl apply -f at-sample-two.yaml
$ watch kubectl get ats,pods
# Check the events in the At object
$ kubectl describe at at-sample-two
```
