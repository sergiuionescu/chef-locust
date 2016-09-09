require_relative 'spec_helper'

context 'LocustIO test suite for slave node' do

  describe port(22) do
    it { should be_listening }
  end

  describe file('/opt/locustio/_test_virtual_user.py') do
    it { should be_file }
  end

  describe command('ps aux | grep python') do
    its(:stdout) { should contain('--slave') }
    its(:stdout) { should contain('--master-host 192.168.222.12') }
    its(:stdout) { should contain('-f /opt/locustio/_test_virtual_user.py') }
    its(:stdout) { should contain('--logfile /opt/locustio/logs/output.log') }
  end

end

