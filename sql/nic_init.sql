LOAD cache_httpfs;
SET s3_region='us-east-1';
SET s3_url_style='path';
SET s3_endpoint='192.168.1.1:9000';
SET s3_access_key_id='minioadmin' ;
SET s3_secret_access_key='minioadmin';
SET s3_use_ssl='false';
SET cache_httpfs_type="in_mem";
SET threads to 64;
.timer on
