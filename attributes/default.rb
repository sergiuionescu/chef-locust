
default['locustio']['pip_packages'] = {
  'locustio' => '0.7.3',
  'pyzmq' => '14.0.1'
}

default['locustio']['node_type'] = 'standalone'
default['locustio']['master_ip'] = '127.0.0.1'
default['locustio']['report_to_datadog'] = false
default['locustio']['test_file'] = 'virtual_user.py'
default['locustio']['test_file_cookbook'] = 'locustio'
default['locustio']['service_file_cookbook'] = 'locustio'
default['locustio']['test_file_base_path'] = '/opt/locustio'
default['locustio']['log_file_dir'] = '/opt/locustio/logs'
default['locustio']['autostart'] = false
default['locustio']['autostart_total_virtual_users'] = 40
default['locustio']['autostart_hatch_rate'] = 5
default['locustio']['webui_port'] = 8089
default['locustio']['master_port'] = 5557
default['locustio']['master_bind_host'] = '*'
default['locustio']['discovery_recipe'] = 'locustio'
default['locustio']['cluster_name'] = 'default'
default['locustio']['script_parameters'] = {}

default['locustio']['from_s3'] = false
default['locustio']['s3_bucket'] = nil
default['locustio']['s3_aws_access_key'] = nil
default['locustio']['s3_aws_secret_access_key'] = nil
default['locustio']['s3_file_path'] = nil
default['locustio']['s3_region'] = 'us-east-1'
default['locustio']['enable_firewall'] = false