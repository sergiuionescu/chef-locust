# Chef LocustIO Cookbook


## Description

This cookbook automates the provisionning of Locust load testing tool.


## Platforms

* Ubuntu 14.04


## Custom Resources

### locustio_node

This resource supports the following attributes

* `instance_name` - The name of the instance (Default: default)
* `node_type` - The type of node, either standalone, master or slave (default: standalone)
* `cluster_name` - The name of the cluster.  Multiple instances for different clusters could be spawned on a single machine.  (default: default)
* `master_ip` - The IP of the master locust node. When specifying an IP, the default behaviour of the master discover with a node search is disabled. (default: nil)
* `test_file` - The test template file to use.  The .erb extension is automatically added. (default: virtual_user.py)
* `test_file_cookbook` - The cookbook from which to find the test file template (default: locustio)
* `from_s3` - Download test script file from S3 (default: false)
* `s3_aws_access_key` - AWS access key (required if downloading from S3, default: nil)
* `s3_aws_secret_access_key` - AWS secret access key (required if downloading from S3, default: nil)
* `s3_bucket` - S3 bucket name (required if downloading from S3, default: nil)
* `s3_file_path` - S3 file path (required if downloading from S3, default: nil)
* `s3_region` -  Geographic region where S3 bucket located (required if downloading from S3, default: nil)
* `service_file_cookbook` - Cookbook from which to take the runit service templates (default: locustio)
* `test_file_base_path` - The base directory where the test will be created. (default: /opt/locustio)
* `log_file_dir` - The base directory where the locust related logs will be located (default: /opt/locustio/logs)
* `autostart` - If the test should be started immediately upon converge finish. (default: false)
* `autostart_total_virtual_users` - If autostart enabled, the number of virtual users/locusts to spawn. (default: 40)
* `autostart_hatch_rate` - The number of virtual users/locusts to spawn per second. (default: 3)
* `webui_port` - The port used to access the HTTP interface (default: 8089)
* `master_port` - Specify the port to be used for the master server (default: 5557)
* `master_bind_host` - Specify the host on which to listen to on the master (default: *, meaning 0.0.0.0)
* `discovery_recipe` - The recipe used when runing the search query for the master node, given no IP was specified. (default: locustio)
* `script_parameters` - The optional variables that can be made available within a custom template. (default: {})
* `enable_firewall` - If set to true, will automatically install and setup the system firewall and allow the following necessary ports  (default: false)
  - 22 (SSH)
  - 8089 or value of `webui_port`
  - 5557, 5558 or value of `master_port` and `master_port` + 1
* `firewall_access_rules` If `enable_firewall` set to true, set allowed sources for each firewall port to be open, for example:

## Usage Examples

** See the included test recipes.


## Test Kitchen

- If running the S3 test suites, you must properly set the values of `s3_aws_secret_access_key`, `s3_aws_access_key`, `s3_bucket`, `s3_file_path`, `s3_region` in the .kitchen.yml file

## Considerations

- This cookbook does not implement any firewall rules.  That being said, you should remember to set those accordingly to a level which you consider to be secure.
- If you start spawning too many locusts, you could start seeing an RPS rate that goes down, eventhough your system being tested might be in good condition.  This can be due to too many locust threads causing too much CPU contention and context-switching.  If running a cluster, my suggestion is to run multiple locust instances, each on a basic server with one or two cores.

## Creator

Alain Lefebvre <hartfordfive 'at' gmail.com>


## License

Covered under the Apache v2 lisense.
