#
#
#

package 'beanstalkd'

cookbook_file '/etc/default/beanstalkd'

service 'beanstalkd' do
  action [:enable, :start]
end