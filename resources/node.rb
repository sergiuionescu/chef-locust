
property :instance_name, kind_of: String, name_property: true, required: true
property :node_type, kind_of: String, default: lazy { node['locustio']['node_type'] }
property :master_ip, kind_of: String, default: lazy { node['locustio']['master_ip'] }
property :report_to_datadog, kind_of: [TrueClass,FalseClass], default: lazy { node['locustio']['report_to_datadog'] }
property :test_file, kind_of: String, default: lazy { node['locustio']['test_file'] }
property :test_file_cookbook, kind_of: String, default: lazy { node['locustio']['test_file_cookbook'] }
property :from_s3, kind_of: [TrueClass,FalseClass], default: lazy { node['locustio']['from_s3'] }
property :s3_aws_access_key, kind_of: String, default: lazy { node['locustio']['s3_aws_access_key'] }
property :s3_aws_secret_access_key, kind_of: String, default: lazy { node['locustio']['s3_aws_secret_access_key'] }
property :s3_bucket, kind_of: String, default: lazy { node['locustio']['s3_bucket'] }
property :s3_file_path, kind_of: String, default: lazy { node['locustio']['s3_file_path'] }
property :s3_region, kind_of: String, default: lazy { node['locustio']['s3_region'] }
property :service_file_cookbook, kind_of: String, default: lazy { node['locustio']['service_file_cookbook'] }
property :test_file_base_path, kind_of: String, default: lazy { node['locustio']['test_file_base_path'] }
property :log_file_dir, kind_of: String, default: lazy { node['locustio']['log_file_dir'] }
property :autostart, kind_of: [TrueClass,FalseClass], default: lazy { node['locustio']['autostart'] }
property :autostart_total_virtual_users, kind_of: Integer, default: lazy { node['locustio']['autostart_total_virtual_users'] }
property :autostart_hatch_rate, kind_of: Integer, default: lazy { node['locustio']['autostart_hatch_rate'] }
property :webui_port, kind_of: Integer, default: lazy { node['locustio']['webui_port'] }
property :master_port, kind_of: Integer, default: lazy { node['locustio']['master_port'] }
property :master_bind_host, kind_of: String, default: lazy { node['locustio']['master_bind_host'] }
property :discovery_recipe, kind_of: String, default: lazy { node['locustio']['webui_port'] }
property :cluster_name, kind_of: String, default: lazy { node['locustio']['cluster_name'] }
property :script_parameters, kind_of: Hash, default: lazy { node['locustio']['script_parameters'] }, required: false
property :enable_firewall, kind_of: [TrueClass,FalseClass], default: lazy { node['locustio']['enable_firewall'] }
property :firewall_access_rules, kind_of: Hash, default: lazy { node['locustio']['firewall_access_rules'] }


load_current_value do
end

action :create do

  include_recipe 'apt::default'
  include_recipe 'runit'

  ['g++','python-zmq'].each do |p|
    package p
  end

  if enable_firewall
    firewall 'default'

    if firewall_access_rules.empty?
      [22, webui_port.to_i, master_port.to_i, (master_port+1).to_i].each do |p|
        firewall_rule "locust-ports-#{p}" do
          port p
          command :allow
          source '0.0.0.0/0'
          notifies :restart, 'firewall[default]'
        end
      end
    else
      [ {'port' => 22, 'source' => firewall_access_rules[22]||'10.0.0.0/8'}, 
        {'port' => webui_port.to_i, 'source' => firewall_access_rules[webui_port.to_i]||'10.0.0.0/8'}, 
        {'port' => master_port.to_i, 'source' => firewall_access_rules[master_port.to_i]||'10.0.0.0/8'}, 
        {'port' => (master_port+1).to_i, 'source' => firewall_access_rules[master_port.to_i]||'10.0.0.0/8'}
      ].each do |rule|
        firewall_rule "locust-ports-#{rule['port']}" do
          port rule['port']
          command :allow
          source rule['source']
          notifies :restart, 'firewall[default]'
        end
      end
    end
  end

  python_runtime 'main' do
    version '2.7'
    options pip_version: true
  end

  node['locustio']['pip_packages'].each do |pname, v|
    python_package pname do
      version v
      user 'root'
      group 'root'
    end
  end

  chef_gem 'httparty' do
    action :install
    compile_time true
  end
  
  directory log_file_dir do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    recursive true
  end

  file "#{log_file_dir}/output.log" do
    action :create
    owner 'root'
    group 'root'
    mode '0644'
  end

  user 'locustio' do
    home test_file_base_path
    shell '/bin/bash'
    password '$6$g6sE/5NAq5$Uxx9V0YUPkF/iNyViv94Qv5WxomDGXpkiFIQvPYe3rAIdPA8MoFEdPW.fC0cku0IEEtygUIs.8s6PDCpk5t3y/'
    manage_home false
    action :create
  end

  if node_type == 'slave' && master_ip == nil
    query = "recipe:#{discovery_recipe.sub('::','\\:\\:')} AND chef_environment:#{node.chef_environment} AND locustio_cluster_name:#{cluster_name} AND locustio_node_type:master"
    nodes = search('node', query)
    if nodes.empty?
      Chef::Log.fatal('Could not find locust master node!')
      Chef::Log.fatal("Query: #{query}")
      raise
    else
      Chef::Log.info("Found Locust master node: #{nodes[0]['ipaddress']}")
      node.default['locustio']['master_ip'] = nodes[0]['ipaddress']
    end
  end

  if from_s3

    missing_params = []

    %w(s3_bucket s3_file_path s3_aws_access_key s3_aws_secret_access_key s3_region).each do |property_name| 
      if new_resource.send(property_name).nil? 
        missing_params.push(property_name)
      end
    end

    if missing_params.size >= 1
      Chef::Log.fatal("Missing parameters: #{missing_params.join(',')}")
      raise
    end

    Chef::Log.info("Getting test file from S3 path: #{s3_bucket}/#{s3_file_path}")

    aws_s3_file "#{test_file_base_path}/#{test_file}" do
      bucket s3_bucket
      remote_path s3_file_path
      aws_access_key s3_aws_access_key
      aws_secret_access_key s3_aws_secret_access_key
      region s3_region
      notifies :restart, "service[locustio-#{instance_name}-#{cluster_name}]" 
    end

  else
    # if it's using the default basic test file, it must at least have a few minimum config values
    if test_file_cookbook == 'locustio' && test_file == 'virtual_user.py' && !script_parameters.has_key?('uri_list')
      Chef::Log.fatal("Base parameters must be passed when using default test script!")
      raise
    end

    template "#{test_file_base_path}/#{test_file}" do
      source "#{test_file}.erb"
      cookbook test_file_cookbook
      owner 'locustio'
      group 'root'
      mode '0644'
      variables({'params' => script_parameters}) if !script_parameters.nil?
      notifies :restart, "service[locustio-#{instance_name}-#{cluster_name}]"
    end
  end

  service_options = {
    'node_type' => node_type,
    'test_file_base_path' => test_file_base_path,
    'test_file' => test_file,
    'log_file_dir' => log_file_dir,
    'webui_port' => webui_port,
    'master_port' => master_port,
    'master_bind_host' => master_bind_host
  }

  if node_type == 'slave' && master_ip.nil? 
    service_options['master_ip'] = node.default['locustio']['master_ip']
  elsif node_type == 'slave' && !master_ip.nil?
    service_options['master_ip'] = master_ip
  end

  runit_service "locustio-#{instance_name}-#{cluster_name}" do
    log_template_name 'locustio'
    run_template_name 'locustio'
    cookbook (service_file_cookbook.nil? ? 'locustio': service_file_cookbook)
    owner 'locustio'
    options(service_options)
    action [:enable, :start]
  end

  if autostart
    Chef::Log.info("Auto starting load test with #{autostart_total_virtual_users} virtual users at a hatch rate of #{autostart_hatch_rate}")
  end

  ruby "auto-start-locustio-#{instance_name}-#{cluster_name}" do
    code <<-EOH
      require 'httparty'
      begin
        HTTParty.post('http://localhost:#{webui_port}/swarm', {:body => {'locust_count' => '#{autostart_total_virtual_users}', 'hatch_rate' => '#{autostart_hatch_rate}'}})
      rescue StandardError => e
      end
    EOH
    action :run
    only_if { autostart == true }
  end

end


action :stop do

  Chef::Log.info("Stoping the current load test")
  # First check if the load test is currently running.  If so, stop it.
  ruby "auto-start-locustio-#{instance_name}-#{cluster_name}" do
    code <<-EOH
      require 'httparty'
      require 'json'
      begin
        response = HTTParty.get('http://localhost:#{webui_port}/stats/requests')
        result = JSON.parse(response.body)
        if result.has_key?('state') && result['state'] == 'running'
          HTTParty.get('http://localhost:#{webui_port}/stop')
        end
      rescue StandardError => e
        puts "[ERROR] Could not complete request: \#{e.message}"
      end
    EOH
    action :run
  end

end

action :disable do

  Chef::Log.info("Stoping the active load test and disabling the Locust service")
  # First check if the load test is currently running.  If so, stop it.
  ruby "auto-start-locustio-#{instance_name}-#{cluster_name}" do
    code <<-EOH
      require 'httparty'
      require 'json'
      begin
        response = HTTParty.get('http://localhost:#{webui_port}/stats/requests')
        result = JSON.parse(response.body)
        if result.has_key?('state') && result['state'] == 'running'
          HTTParty.get('http://localhost:#{webui_port}/stop')
        end
      rescue StandardError => e
        puts "[ERROR] Could not complete request: \#{e.message}"
      end
    EOH
    action :run
  end

  runit_service "locustio-#{instance_name}-#{cluster_name}" do
    action :disable
  end

  if enable_firewall
    [22, webui_port.to_i, master_port.to_i, (master_port+1).to_i].each do |p|
      firewall_rule "locust-ports-#{p}" do
        port p
        command :allow
        notifies :restart, 'firewall[default]'
      end
    end
  end

end

action :delete do

  Chef::Log.info("Stoping the active load test and deleting the Locust service and related dependencies")
  # First chec if the load test is currently running.  If so, stop it.
  ruby "auto-start-locustio-#{instance_name}-#{cluster_name}" do
    code <<-EOH
      require 'json'
      begin
        response = HTTParty.get('http://localhost:#{webui_port}/stats/requests')
        result = JSON.parse(response.body)
        if result.has_key?('state') && result['state'] == 'running'
          HTTParty.get('http://localhost:#{webui_port}/stop')
        end
      rescue StandardError => e
        puts "[ERROR] Could not complete request: \#{e.message}"
      end
    EOH
    action :run
  end

  ['g++','python-zmq'].each do |p|
    package p do
      action :remove
    end
  end
  
  python_runtime 'main' do
    version '2.7'
    action :uninstall
  end

  node['locustio']['pip_packages'].each do |pname, v|
    python_package pname do
      action :remove
    end
  end

  file "#{log_file_dir}/output.log" do
    action :delete
  end

  directory test_file_base_path do
    action :delete
    recursive true
  end

  runit_service "locustio-#{instance_name}-#{cluster_name}" do
    action :disable
  end

  if enable_firewall
    [22, webui_port.to_i, master_port.to_i, (master_port+1).to_i].each do |p|
      firewall_rule "locust-ports-#{p}" do
        port p
        command :allow
        notifies :restart, 'firewall[default]'
      end
    end
  end

end
