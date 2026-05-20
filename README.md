# S3-to-DB-network-bench

### Usage
#### Setup
```bash
just setup
```
- Creates network namespaces
- Mounts disk

#### Terminal 1
```bash
just runner="taskset -c 16-31" minio_netns
```
- Starts MinIO


#### Terminal 2
```bash
just args="-f ./sql/tpch/s3_01.sql" duckdb_netns
```
- Starts duckdb in corresponding network namespace
- Sets up credentials and config for S3 requests
- If args are provided: Executes corresponding query

#### Teardown
```bash
just clean
```
- Destroys namespaces and unmounts disk on exit


### DuckVM
Project includes a virtual machine with an attached virtual nic
```bash
just duckVM
```
This can be used together with the `minio_netns` target
- Inside the VM (after starting minio on the host) 
```bash
just setup
just ping
```
