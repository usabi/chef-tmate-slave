port = node['port']
host = node['host']

git "/tmp/tmate-slave" do
  repository "https://github.com/nviennot/tmate-slave.git"
  action :sync
  user "root"
  group "root"
end

execute "create_keys" do
  cwd "/tmp/tmate-slave"
  command "./create_keys.sh > /root/tmate-slave-footprints.txt"
  creates '/root/tmate-slave-footprints.txt'
  notifies :run, "execute[copy_keys]", :immediately
end

execute "copy_keys" do
  cwd "/tmp/tmate-slave"
  command "cp -r keys /root/"
  action :nothing
end

script "compile_tmate-slave_part1" do
    interpreter "bash"
      user "root"
      cwd "/tmp/tmate-slave"
      code <<-EOH
        STATUS=0
        cd /tmp/tmate-slave
        ./autogen.sh || STATUS=1
        ./configure || STATUS=1
        make || STATUS=1
        if ps ax|grep tmate-slave|grep -v grep; then
          service tmate-slave stop
        fi
        cp tmate-slave /usr/local/bin || STATUS=1
        chmod 755 /usr/local/bin/tmate-slave || STATUS=1
        exit $STATUS
      EOH
end

poise_service 'tmate-slave' do
  command "/usr/local/bin/tmate-slave -k /root/keys -p #{port} -h #{host}"
  action :enable
  restart_on_update true
end
