
locustio_node 'tester' do
  node_type 'master'
  report_to_datadog true
  test_file '_test_virtual_user.py'
  script_parameters({'uri_list' => {'uri' => '/', 'weight' => '20', 'identifier' => 'home'}})
  autostart false
  autostart_total_virtual_users 100
  autostart_hatch_rate 5
end
