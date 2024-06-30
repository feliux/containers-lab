# Istio integrations

[Prometheus](https://prometheus.io/) is an open source monitoring system and **time-series database for metrics**. You can use Prometheus with Istio to record metrics that track the health of Istio and applications within the service mesh. You can visualize metrics using tools like Grafana and Kiali.

[Grafana](https://grafana.com/) is a common **dashboard** used for cloud native observability. Grafana integrates well with time-series databases such as Prometheus and offers a language for creating custom dashboards for meaningful views into your metrics. Grafana is an open source monitoring solution that can be used to configure dashboards for Istio. You can use Grafana to monitor the health of Istio and applications within the service mesh.

Istio allows you to choose several different tracing frameworks such as Jaeger, Zipkin, and Lightstep. Jaeger tends to be the supported default with Istio since it supports the collections of tools, APIS and SDK from OpenTelemetry. [Jaeger](https://www.jaegertracing.io/) is an open source end to end distributed **tracing system**, allowing users to monitor and troubleshoot transactions in complex distributed systems. Jaeger implements the OpenTracing specification.

[Kiali](https://kiali.io/) is an observability console for Istio with service mesh configuration and validation capabilities. It helps you understand the structure and health of your service mesh by monitoring traffic flow to infer the topology and report errors. Kiali provides detailed metrics and a basic Grafana integration, which can be used for advanced queries. Distributed tracing is provided by integration with Jaeger.
