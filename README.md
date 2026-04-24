# S3-to-DB-network-bench


### Usage
#### Terminal 1
```bash
nix run .#minio-server
```
- Creates network namespaces
- Mounts disk
- Starts MinIO
- Destroys namespaces and unmounts disk on exit


#### Terminal 2
```bash
nix run .#duckdb-minio
```
- Starts duckdb in corresponding network namespace
- Sets up credentials and config for S3 requests
