
locustio_node 'tester' do
  script_parameters({
    'base_url' => 'www.example.com',
    'uri_list' => [ 
      {'weight' => 30, 'identifier' => 'link-1', 'uri' => '/test1'},
      {'weight' => 30, 'identifier' => 'link-2', 'uri' => '/test2'},
      {'weight' => 20, 'identifier' => 'link-3', 'uri' => '/test3'},
      {'weight' => 20, 'identifier' => 'link-4', 'uri' => '/test4'}
    ],
    'min_wait_time' => 800,
    'max_wait_time' => 4000
  })
  enable_firewall true
  webui_port 80
  firewall_access_rules({22 => '0.0.0.0/0', 80 => '0.0.0.0/0', 5557 => '10.0.0.0/8', 5558 => '10.0.0.0/8'})
end