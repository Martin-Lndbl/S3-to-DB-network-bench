# S3-to-DB-network-bench


### Usage
#### Terminal 1
```bash
nix run .#nic_minio
```
- Creates network namespaces
- Mounts disk
- Starts MinIO
- Destroys namespaces and unmounts disk on exit


#### Terminal 2
```bash
nix run .#nic_duckdb -- -f ./sql/tpch/s3_01.sql
```
- Starts duckdb in corresponding network namespace
- Sets up credentials and config for S3 requests

### cache_httpfs

To see the effect of the cache_httpfs extension, use the repeat queries (e.g. `sql/tpch/s3_01_repeat.sql`).
