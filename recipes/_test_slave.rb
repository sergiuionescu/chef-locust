
locustio_node 'tester' do
  node_type 'slave'
  report_to_datadog true
  discovery_recipe 'locustio'
  master_ip '192.168.222.12'
  test_file '_test_virtual_user.py'
  script_parameters({'uri_list' => {'uri' => '/', 'weight' => '20', 'identifier' => 'home'}})
end
