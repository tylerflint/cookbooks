include_recipe "apt"
include_recipe "build-essential"

node[:ruby][:deps].each do |pkg|
  package pkg do
    action :install
  end
end

execute "get ruby-#{ node[:ruby][:version] }" do
  cwd "/usr/local/src"
  command "wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ node[:ruby][:version] }.tar.bz2"
  creates "/usr/local/src/ruby-#{ node[:ruby][:version] }.tar.bz2"
end

execute "unpack ruby-#{ node[:ruby][:version] }" do
  cwd '/usr/local/src'
  command "tar xjf ruby-#{ node[:ruby][:version] }.tar.bz2"
  creates "/usr/local/src/ruby-#{ node[:ruby][:version] }"
end

execute "build ruby-#{ node[:ruby][:version] }" do
  cwd "/usr/local/src/ruby-#{ node[:ruby][:version] }"
  command "./configure && make && make install"
  not_if { `which ruby && ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) } | wc -l`.to_i != 0 }
end

%w( openssl readline ).each do |ext|
  execute "configure & make ruby-#{ node[:ruby][:version] } #{ext} support" do
    cwd "/usr/local/src/ruby-#{ node[:ruby][:version] }/ext/#{ext}"
    command "ruby extconf.rb && make && make install"
    not_if { `which ruby && ruby -v | grep #{ node[:ruby][:version].gsub( '-', '' ) } | wc -l`.to_i != 0 }
  end
end

%w( bundler ohai chef ).each do |g|
  gem_package g do
    action :install
    gem_binary('/usr/local/bin/gem')
  end
end