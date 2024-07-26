package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// AtSpec defines the desired state of At
type AtSpec struct {
	Schedule string `json:"schedule,omitempty"`
	Command  string `json:"command,omitempty"`
}

// AtStatus defines the observed state of At
type AtStatus struct {
	Phase string `json:"phase,omitempty"`
}

const (
	PhasePending = "PENDING"
	PhaseRunning = "RUNNING"
	PhaseDone    = "DONE"
)

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:JSONPath=".spec.schedule", name=Schedule, type=string
// +kubebuilder:printcolumn:JSONPath=".status.phase", name=Phase, type=string
// At is the Schema for the ats API
type At struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   AtSpec   `json:"spec,omitempty"`
	Status AtStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// AtList contains a list of At
type AtList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []At `json:"items"`
}

func init() {
	SchemeBuilder.Register(&At{}, &AtList{})
}
