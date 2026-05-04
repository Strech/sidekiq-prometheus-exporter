# Official Helm chart

This is an official Helm chart for [sidekiq-prometheus-exporter](https://github.com/Strech/sidekiq-prometheus-exporter)
gem. It uses Docker image published on the [Docker hub](https://hub.docker.com/r/strech/sidekiq-prometheus-exporter).

## Installation

First of all add the chart repository

```console
$ helm repo add strech https://strech.github.io/sidekiq-prometheus-exporter
"strech" has been added to your repositories

$ helm repo list
NAME    URL
strech  https://strech.github.io/sidekiq-prometheus-exporter
```

Then you can install the chart, let's say with the release name `sidekiq-metrics`

**Helm v2**

```console
$ helm install strech/sidekiq-prometheus-exporter --name sidekiq-metrics
```

**Helm v3**

```console
$ helm install sidekiq-metrics strech/sidekiq-prometheus-exporter
```

## Configuration

You can try out that configuration by using `--dry-run` and `--values` on
install (examples using **Helm v3**)

```console
$ helm install sidekiq-metrics strech/sidekiq-prometheus-exporter --values myvalues.yaml --dry-run
```

or you can try out just one value via `--set`

```console
$ helm install sidekiq-metrics strech/sidekiq-prometheus-exporter --set serviceAccount.create=false --dry-run
```

| Parameter                      | Description                                                                                      | Default                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------ | ------------------------------------ |
| `nameOverride`                 | Override the resource name prefix                                                                | `nil`                                |
| `fullnameOverride`             | Override the full resource names                                                                 | `nil`                                |
| `image.registry`               | Image registry                                                                                   | `docker.io`                          |
| `image.repository`             | Image repository                                                                                 | `strech/sidekiq-prometheus-exporter` |
| `image.tag`                    | Image tag                                                                                        | `0.2.0-4`                            |
| `image.pullPolicy`             | Image pull policy                                                                                | `IfNotPresent`                       |
| `image.pullSecrets`            | Image pull secrets                                                                               | `nil`                                |
| `containerPort`                | Port for the exporter to bind on                                                                 | `9292`                               |
| `resources`                    | CPU/Memory resource requests/limits                                                              | `nil`                                |
| `nodeSelector`                 | Node labels for pod assignment                                                                   | `nil`                                |
| `tolerations`                  | Toleration labels for pod assignment                                                             | `nil`                                |
| `affinity`                     | Affinity settings for pod assignment                                                             | `nil`                                |
| `securityContext`              | Security Context for the pod                                                                     | `nil`                                |
| `podLabels`                    | Pod labels additional to the default                                                             | `nil`                                |
| `podAnnotations`               | Pod annotations                                                                                  | `nil`                                |
| `livenessProbe`                | LivenessProbe settings for tcpSocket mapping to containerPort                                    | (See `values.yaml`)                  |
| `readinessProbe`               | ReadinessProbe settings for tcpSocket mapping to containerPort                                   | (See `values.yaml`)                  |
| `service.type`                 | Kubernetes service type                                                                          | `ClusterIP`                          |
| `service.port`                 | Kubernetes port where service is exposed                                                         | `80`                                 |
| `env`                          | An environment variables for metrics container (exclusive with `envFrom`)                        | `nil`                                |
| `envFrom.type`                 | Type of resource configMapRef/secretRef to source environment variables from                     | `nil`                                |
| `envFrom.name`                 | Name of Secret/ConfigMap to source environment variables from                                    | `nil`                                |
| `serviceMonitor.enabled`       | Whether serviceMonitor resource should be deployed                                               | `false`                              |
| `serviceMonitor.path`          | The endpoint of the service to be scraped                                                        | `/metrics`                           |
| `serviceMonitor.interval`      | Duration between 2 consecutive scrapes                                                           | `1m`                                 |
| `serviceMonitor.scrapeTimeout` | Timeout for each scrape request                                                                  | `nil`                                |
| `serviceMonitor.labels`        | Labels to add to the service monitor object                                                      | `nil`                                |
| `podMonitoring.enabled`        | Whether PodMonitoring (GMP) should be deployed                                                   | `false`                              |
| `podMonitoring.path`           | The endpoint of the pod to be scraped                                                            | `/metrics`                           |
| `podMonitoring.interval`       | Duration between 2 consecutive scrapes                                                           | `1m`                                 |
| `podMonitoring.labels`         | Labels to add to the PodMonitoring object                                                        | `nil`                                |
| `serviceAccount.create`        | Specifies whether a service account should be created                                            | `true`                               |
| `serviceAccount.name`          | Name of the service account (if not set will be generated from chart full name)                  | `nil`                                |
| `rbac.create`                  | If true, create & use RBAC resources (:anger: works with `envFrom` and `serviceAccount` enabled) | `false`                              |

## How to uninstall?

If you already have release `sidekiq-metics` running and want to remove it

```console
$ helm delete --purge sidekiq-metics
```

:bulb: The command above removes all the Kubernetes components associated with the chart and deletes the release.
