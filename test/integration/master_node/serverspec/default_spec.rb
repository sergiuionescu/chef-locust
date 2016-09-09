require_relative 'spec_helper'

context 'LocustIO test suite for master node' do

  [22, 8089].each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end

  describe file('/opt/locustio/_test_virtual_user.py') do
    it { should be_file }
  end

  describe command('ps aux | grep python') do
    its(:stdout) { should contain('--master') }
    its(:stdout) { should contain('-f /opt/locustio/_test_virtual_user.py') }
    its(:stdout) { should contain('--logfile /opt/locustio/logs/output.log') }
  end

end

