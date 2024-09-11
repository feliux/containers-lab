# Kubernetes API Versioning

For extensibility reasons, Kubernetes supports multiple API versions at different API paths, such as `/api/v1` or `/apis/extensions/v1beta1`. Different API versions imply different levels of stability and support.

- Alpha level (e.g., v1alpha1 ) is usually disabled by default; support for a feature may be dropped at any time without notice and should be used only in short-lived testing clusters.
- Beta level (e.g., v2beta3 ) is enabled by default, meaning that the code is well tested; however, the semantics of objects may change in incompatible ways in a subsequent beta or stable release.
- Stable (generally available, or GA) level (e.g., v1 ) will appear in released software for many subsequent versions.

> There is no such thing as “one object is in v1 in the cluster, and another object is in v1beta1 in the cluster.” Instead, every object can be returned as a v1 representation or in the v1beta1 representation, as the cluster user desires.

> The core group is located under `/api/v1` and not, as one would expect, under `/apis/core/v1`, for historic reasons. The core group existed before the concept of an API group was introduced.
