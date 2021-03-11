# Official Docker image

[0]: https://github.com/Strech/sidekiq-prometheus-exporter
[1]: https://www.iana.org/assignments/uri-schemes/prov/redis
[2]: https://github.com/resque/redis-namespace
[3]: https://github.com/redis/redis-rb/tree/v4.1.3#sentinel-support
[4]: https://github.com/mperham/sidekiq/issues/4479

This is an official Docker image for [sidekiq-prometheus-exporter][0]
gem.

It combines some approaches which were already published as images by other
devs and at the same time brings more flexibility for the stock configuration
and applies recommended Docker best practices.

:warning: The Docker image currently supports **only** standards metrics.

## Supported ENVs

Required

- `REDIS_URL` - [RFC 3986 generic URI][1], exclusive with `REDIS_HOST`
- `REDIS_HOST` - a Redis host, exclusive with `REDIS_URL` (default: `localhost`)

Optional

- `REDIS_SSL` - a flag to enable Redis SSL URL scheme (default: `false`)
- `REDIS_PORT` - a Redis port (default: `6379`)
- `REDIS_PASSWORD` - a Redis password (if you need one)
- `REDIS_DB_NUMBER` - a Redis database number (default: `0`)
- `REDIS_NAMESPACE` - a Redis [namespace][2] name (if you have separated sidekiq)
- `REDIS_SENTINELS` - a list of comma separated Redis urls (like `REDIS_URL`, but for sentinels)
- `REDIS_SENTINEL_ROLE` - a role within the [sentinel][3] to connect (default: `master`)
- `REDIS_DISABLE_CLIENT_ID` - a flag to disable `CLIENT` command in [Sidekiq][4]

:bulb: Note, that `REDIS_URL` and `REDIS_HOST` are exclusive. Since `REDIS_HOST` is more
atomic value it will be checked after `REDIS_URL`.

:bulb: `REDIS_SENTINELS` will be parsed with `URI`, because of that it's
mandatory for them to be formatted with protocol `redis://...`.

:bulb: `REDIS_DISABLE_CLIENT_ID` might be required if a SaaS Redis provider is being used.

## Examples

If you don't have a running Redis instance, you can quickly spin an empty to
practice.

```bash
$ docker run -d --rm --name redis-instance redis
```

and then run an exporter

```bash
$ docker run -it --rm \
             --link redis-instance \
             -p 9292:9292 \
             -e REDIS_URL=redis://redis-instance \
             strech/sidekiq-prometheus-exporter
```
