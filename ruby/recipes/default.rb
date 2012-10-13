include_recipe "apt"
include_recipe "build-essential"

%w( wget zlib1g-dev libssl-dev libffi-dev libxml2-dev libncurses5-dev libreadline6-dev ).each do |pkg|
  package pkg do
    action :install
  end
end

execute "get #{ node[:ruby][:version] }" do
  cwd "/usr/local/src"
  command "wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ node[:ruby][:version] }.tar.bz2"
  creates "/usr/local/src/ruby-#{ node[:ruby][:version] }.tar.bz2"
end

execute "unpack #{ node[:ruby][:version] }" do
  cwd '/usr/local/src'
  command "tar xjf ruby-#{ node[:ruby][:version] }.tar.bz2"
  creates "/usr/local/src/ruby-#{ node[:ruby][:version] }" }
end

execute "configure & make #{ node[:ruby][:version] }" do
  user "root"
  command "cd /usr/local/src/ruby-#{ node[:ruby][:version] } && ./configure && make && make install"
  not_if { `ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) } | grep wc -l`.to_i != 0 }
end

%w( openssl readline ).each do |ext|
  execute "configure & make #{ node[:ruby][:version] } #{ext} support" do
    user "root"
    command "cd /usr/local/src/ruby-#{ node[:ruby][:version] }/ext/#{ext}/ && ruby extconf.rb && make && make install"
    not_if { `ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) } | grep wc -l`.to_i != 0 }
  end
end

%w( bundler ohai chef ).each do |g|
  gem_package g do
    action :install
    gem_binary('/usr/local/bin/gem')
  end
end