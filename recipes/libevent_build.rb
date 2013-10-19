#
# package installs
#
case node["platform"]
  when "debian", "ubuntu"
   %w{libevent-dev}.each do |pkg|
   package pkg do
     action :purge
   end
end

when "redhat", "centos", "fedora"
  execute "echo 'stupid redhat'"
end

remote_file "/tmp/libevent-2.0.21-stable.tar.gz" do
  source "https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"
  action :create_if_missing
  owner 'root'
  group 'root'
end

script "compile_libevent-2.0.21" do
    interpreter "bash"
    user "root"
    cwd "/tmp"
    code <<-EOH
      STATUS=0
      tar xvzf libevent-2.0.21-stable.tar.gz || STATUS=1
      cd libevent-2.0.21-stable || STATUS=1
      ./configure || STATUS=1
      make || STATUS=1
      make install || STATUS=1
      cd /tmp || STATUS=1
      rm -rf libevent* || STATUS=1
      exit $STATUS
    EOH
end

