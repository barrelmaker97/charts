# Obscura chart

This chart bundles PostgreSQL, Valkey, and a standalone RustFS S3-compatible
object store for a fresh test installation. RustFS is a pinned chart dependency
from [charts.rustfs.com](https://charts.rustfs.com). The default server image is
`ghcr.io/obscura-messaging/obscura-server:0.9.6`.

```sh
helm dependency build charts/obscura
helm install obscura charts/obscura
```

The bundled RustFS instance uses the cluster's default StorageClass and keeps
its data PVC after uninstall. A dynamic default StorageClass is required. The
chart's example database, Valkey, and RustFS passwords are **for development
only**; PostgreSQL and Valkey do not persist data with the default values.
Supply unique credentials, persistent volumes for all stateful dependencies,
and a backup/restore plan before using the chart with real data.

To configure bundled storage, set `rustfs.secret.rustfs.access_key` and
`rustfs.secret.rustfs.secret_key` to matching non-default credentials. The
Obscura server and bucket initialization both use these values. Alternatively,
set `rustfs.secret.existingSecret` to a Secret containing `RUSTFS_ACCESS_KEY`
and `RUSTFS_SECRET_KEY`; the Obscura server reads the same Secret. The
`obscura.storage.bucket` value selects the bucket, which an init container
creates on startup. `helm test` checks S3 write, read, head, and delete.

For an object store already available in the cluster, disable the bundled
RustFS dependency and provide an existing bucket and S3 credentials:

```yaml
rustfs:
  enabled: false
obscura:
  storage:
    endpoint: https://s3.example.com
    bucket: obscura-storage
    region: us-east-1
    forcePathStyle: true
    existingSecret:
      name: obscura-s3
      accessKeyKey: access-key
      secretKeyKey: secret-key
```

The Secret must exist in the release namespace. Instead of `existingSecret`,
`obscura.storage.accessKey` and `secretKey` can be supplied together; avoid
putting production credentials in a checked-in values file. The chart does not
create buckets in external storage.

## Upgrading from the MinIO chart

Version `0.13.0` changes the bundled store from MinIO to RustFS. It **does not
migrate any objects or existing MinIO data**. Do not upgrade an installation
that contains data in the old MinIO deployment without first planning a
separate export/import, verifying the new bucket contents, and retaining a
rollback path. You can leave the old store running and set `rustfs.enabled:
false` with an explicit endpoint and credentials while planning that move.
The chart's upstream dependency test intentionally treats this `0.x` minor
version change as incompatible and does not test an in-place upgrade.
