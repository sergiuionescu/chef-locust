require_relative 'spec_helper'

context 'LocustIO test suite for standalone node' do

  [22, 8089].each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end

  describe command('ps aux | grep python') do
    its(:stdout) { should contain('/usr/local/bin/locust --port 80 -f /opt/locustio/virtual_user.py --logfile=/opt/locustio/logs/output.log') }
  end


  describe command('ps aux | grep python') do
    its(:stdout) { should_not match(%r#/usr/local/bin/locust.*--master-host=#) }
    its(:stdout) { should_not match(%r#/usr/local/bin/locust.*--slave#) }
    its(:stdout) { should match(%r#/usr/local/bin/locust.*-f /opt/locustio/_test_virtual_user.py#) }
    its(:stdout) { should match(%r#/usr/local/bin/locust.*--logfile=/opt/locustio/logs/output.log#) }
  end

end

