name 'base'

run_list 'os-hardening::default' # audit::default

default_source :supermarket

cookbook 'os-hardening', path: '../cookbooks/os-hardening'

# disable audit mode via policy, using hab instead
 
# default['audit']['reporter'] = 'chef-automate'
# default['audit']['fetcher'] = 'chef-automate'
# 
# default['audit']['profiles'].push(
#   {
#     'name': 'cis-wrapper',
#     'compliance': 'admin/cis-centos7-lv1-wrapper'
#   }
# )
