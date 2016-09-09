
locustio_node 'tester' do
  test_file '_test_virtual_user.py'
  script_parameters({'secret_token' => 'asdf1234'})
  autostart false
  autostart_total_virtual_users 5
  autostart_hatch_rate 1
  webui_port 80
end