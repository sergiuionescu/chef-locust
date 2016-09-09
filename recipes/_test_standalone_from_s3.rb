
locustio_node 'tester' do
  test_file node['locustio']['test_file']
  from_s3 true
  s3_bucket node['locustio']['s3_bucket']
  s3_file_path node['locustio']['s3_file_path']
  s3_region node['locustio']['s3_region']
  s3_aws_access_key node['locustio']['s3_aws_access_key']
  s3_aws_secret_access_key node['locustio']['s3_aws_secret_access_key']
end