# sidekiq-prometheus-exporter helm chart

## Installing the Chart

To install the chart with the release name `sidekiq-prometheus-exporter`:

```console
$ git clone git@github.com:Strech/sidekiq-prometheus-exporter.git
helm install --name sidekiq-prometheus-exporter ./helm-charts/sidekiq-prometheus-exporter
```

## Uninstalling the Chart

To uninstall/delete the `sidekiq-prometheus-exporter` deployment:

```console
$ helm delete --purge sidekiq-prometheus-exporter
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

| Parameter                       | Description                                                                                 | Default                             |
|---------------------------------|---------------------------------------------------------------------------------------------|-------------------------------------|
| `replicaCount`                  | Number of nodes                                                                             | `1`                                 |
| `image.repository`              | Image repository                                                                            | `strech/sidekiq-prometheus-exporter`|
| `image.tag`                     | Image tag                                                                                   | `latest`                            |
| `image.pullPolicy`              | Image pull policy                                                                           | `IfNotPresent`                      |
| `imagePullSecrets`              | Image pull secrets                                                                          | `[]`                                |
| `nameOverride`                  | Override the resource name prefix                                                           | `""`                                |
| `fullnameOverride`              | Override the full resource names                                                            | `""`                                |
| `service.type`                  | Kubernetes service type                                                                     | `ClusterIP`                         |
| `service.port`                  | Kubernetes port where service is exposed                                                    | `80`                                |
| `containerPort`                 | Port for the exporter to bind on                                                            | `9292`                              |
| `resources`                     | CPU/Memory resource requests/limits                                                         | `{}`                                |
| `nodeSelector`                  | Node labels for pod assignment                                                              | `{}`                                |
| `tolerations`                   | Toleration labels for pod assignment                                                        | `[]`                                |
| `affinity`                      | Affinity settings for pod assignment                                                        | `{}`                                |
| `externalEnvVars.type`          | Type of resource Secret/ConfigMap to source environment variables from.                     | `ConfigMap`                         |
| `externalEnvVars.name`          | Name of Secret/ConfigMap to source environment variables from. Blank to not source either.  | `""`                                |
| `servicemonitor.enabled`        | Whether servicemonitor resource should be deployed                                          | `true`                              |
| `servicemonitor.path`           | The endpoint of the service to be scraped                                                   | `/metrics`                          |
| `servicemonitor.interval`       | Duration between 2 consecutive scrapes                                                      | `10s`                               |
| `servicemonitor.labels`         | Labels to add to the service monitor object                                                 | `{}`                                |
| `servicemonitor.scrapeTimeout`  | Timeout for each scrape request                                                             | `5s`                                |
| `rbac.create`                   | If true, create & use RBAC resources                                                        | `false`                             |
| `serviceAccount.create`         | Specifies whether a service account should be created.                                      | `true`                              |
| `serviceAccount.name`           | Name of the service account.                                                                | `""`                                |
| `serviceAccount.annotations`    | Custom annotations for service  account.                                                    | `{}`                                |
| `securityContext`               | Security Context for the pod                                                                | `{runAsUser: 65534}`                |
