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
TODO: Revisit parameters

| Parameter                      | Description                                                                                | Default                              |
| ------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------ |
| `image.repository`             | Image repository                                                                           | `strech/sidekiq-prometheus-exporter` |
| `image.tag`                    | Image tag                                                                                  | `0.1.13`                             |
| `image.pullPolicy`             | Image pull policy                                                                          | `IfNotPresent`                       |
| `imagePullSecrets`             | Image pull secrets                                                                         | `[]`                                 |
| `nameOverride`                 | Override the resource name prefix                                                          | `""`                                 |
| `fullnameOverride`             | Override the full resource names                                                           | `""`                                 |
| `service.type`                 | Kubernetes service type                                                                    | `ClusterIP`                          |
| `service.port`                 | Kubernetes port where service is exposed                                                   | `80`                                 |
| `containerPort`                | Port for the exporter to bind on                                                           | `9292`                               |
| `resources`                    | CPU/Memory resource requests/limits                                                        | `{}`                                 |
| `nodeSelector`                 | Node labels for pod assignment                                                             | `{}`                                 |
| `tolerations`                  | Toleration labels for pod assignment                                                       | `[]`                                 |
| `affinity`                     | Affinity settings for pod assignment                                                       | `{}`                                 |
| `externalEnvVars.type`         | Type of resource Secret/ConfigMap to source environment variables from.                    | `ConfigMap`                          |
| `externalEnvVars.name`         | Name of Secret/ConfigMap to source environment variables from. Blank to not source either. | `""`                                 |
| `serviceMonitor.enabled`       | Whether serviceMonitor resource should be deployed                                         | `true`                               |
| `serviceMonitor.path`          | The endpoint of the service to be scraped                                                  | `/metrics`                           |
| `serviceMonitor.interval`      | Duration between 2 consecutive scrapes                                                     | `1m`                                 |
| `serviceMonitor.labels`        | Labels to add to the service monitor object                                                | `{}`                                 |
| `serviceMonitor.scrapeTimeout` | Timeout for each scrape request                                                            | `10s`                                |
| `rbac.create`                  | If true, create & use RBAC resources                                                       | `true`                               |
| `serviceAccount.create`        | Specifies whether a service account should be created.                                     | `true`                               |
| `serviceAccount.name`          | Name of the service account.                                                               | `""`                                 |
| `securityContext`              | Security Context for the pod                                                               | `{}`                                 |
| `livenessProbe`                | LivenessProbe settings for tcpSocket mapping to containerPort                              | (See `values.yaml`)                  |
| `readinessProbe`               | ReadinessProbe settings for tcpSocket mapping to containerPort                             | (See `values.yaml`)                  |

## How to uninstall?

If you already have release `sidekiq-metics` running and want to remove it

```console
$ helm delete --purge sidekiq-metics
```

:bulb: The command above removes all the Kubernetes components associated with the chart and deletes the release.
