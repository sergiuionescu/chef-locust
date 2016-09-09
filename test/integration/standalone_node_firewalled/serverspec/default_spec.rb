require_relative 'spec_helper'

context 'LocustIO test suite for standalone node with firewall enabled' do

  describe port(8089) do
    it { should_not be_listening }
  end

  describe port(80) do
    it { should be_listening.on('0.0.0.0') }
  end

  describe port(22) do
    it { should be_listening.on('0.0.0.0') }
  end

  describe iptables do
    it { should have_rule('-p tcp -m tcp --dport 22 -j ACCEPT') }
    it { should have_rule('-p tcp -m tcp --dport 80 -j ACCEPT') }
    it { should have_rule('-s 10.0.0.0/8 -p tcp -m tcp --dport 5557 -j ACCEPT') }
    it { should have_rule('-s 10.0.0.0/8 -p tcp -m tcp --dport 5558 -j ACCEPT') }
  end

  describe command('ps aux | grep python') do
    its(:stdout) { should contain('/usr/local/bin/locust --port 80 -f /opt/locustio/virtual_user.py --logfile=/opt/locustio/logs/output.log') }
  end

  describe file('/opt/locustio/virtual_user.py') do
    it { should be_file }
  end

end

