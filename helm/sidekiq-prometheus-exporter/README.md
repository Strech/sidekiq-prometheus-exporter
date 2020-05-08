# Official Helm chart

This is an official Helm chart for [sidekiq-prometheus-exporter](https://github.com/Strech/sidekiq-prometheus-exporter)
gem. It uses Docker image published on the [Docker hub](https://hub.docker.com/r/strech/sidekiq-prometheus-exporter).

## Installation

To install the chart with the release name `sidekiq-metrics`

```console
$ git clone git@github.com:Strech/sidekiq-prometheus-exporter.git
helm install --name sidekiq-metrics ./helm/sidekiq-prometheus-exporter
```

## Configuration

TODO: Provide examples of values to be set via file / via arguments

| Parameter                      | Description                                                                       | Default                              |
| ------------------------------ | --------------------------------------------------------------------------------- | ------------------------------------ |
| `nameOverride`                 | Override the resource name prefix                                                 | `nil`                                |
| `fullnameOverride`             | Override the full resource names                                                  | `nil`                                |
| `image.registry`               | Image registry                                                                    | `docker.io`                          |
| `image.repository`             | Image repository                                                                  | `strech/sidekiq-prometheus-exporter` |
| `image.tag`                    | Image tag                                                                         | `0.1.13`                             |
| `image.pullPolicy`             | Image pull policy                                                                 | `IfNotPresent`                       |
| `image.pullSecrets`            | Image pull secrets                                                                | `nil`                                |
| `containerPort`                | Port for the exporter to bind on                                                  | `9292`                               |
| `resources`                    | CPU/Memory resource requests/limits                                               | `nil`                                |
| `nodeSelector`                 | Node labels for pod assignment                                                    | `nil`                                |
| `tolerations`                  | Toleration labels for pod assignment                                              | `nil`                                |
| `affinity`                     | Affinity settings for pod assignment                                              | `nil`                                |
| `securityContext`              | Security Context for the pod                                                      | `nil`                                |
| `livenessProbe`                | LivenessProbe settings for tcpSocket mapping to containerPort                     | (See `values.yaml`)                  |
| `readinessProbe`               | ReadinessProbe settings for tcpSocket mapping to containerPort                    | (See `values.yaml`)                  |
| `service.type`                 | Kubernetes service type                                                           | `ClusterIP`                          |
| `service.port`                 | Kubernetes port where service is exposed                                          | `80`                                 |
| `env`                          | An environment variables for metrics container (exclusive with envFrom)           | `nil`                                |
| `envFrom.type`                 | Type of resource configMapRef/secretRef to source environment variables from      | `nil`                                |
| `envFrom.name`                 | Name of Secret/ConfigMap to source environment variables from                     | `nil`                                |
| `serviceMonitor.enabled`       | Whether serviceMonitor resource should be deployed                                | `false`                              |
| `serviceMonitor.path`          | The endpoint of the service to be scraped                                         | `/metrics`                           |
| `serviceMonitor.interval`      | Duration between 2 consecutive scrapes                                            | `1m`                                 |
| `serviceMonitor.scrapeTimeout` | Timeout for each scrape request                                                   | `nil`                                |
| `serviceMonitor.labels`        | Labels to add to the service monitor object                                       | `{}`                                 |
| `rbac.create`                  | If true, create & use RBAC resources (only if envFrom and serviceAccount enabled) | `false`                              |
| `serviceAccount.create`        | Specifies whether a service account should be created                             | `true`                               |
| `serviceAccount.name`          | Name of the service account (if not set will be generated from chart full name)   | `nil`                                |

## How to uninstall?

If you already have release `sidekiq-metics` running and want to remove it

```console
$ helm delete --purge sidekiq-metics
```

:bulb: The command above removes all the Kubernetes components associated with the chart and deletes the release.
