name 'base'

run_list 'os-hardening::default' # , 'audit::default'

default_source :supermarket

cookbook 'os-hardening', path: '../cookbooks/os-hardening'

# default['audit']['reporter'] = 'chef-automate'
# default['audit']['profiles'].push(
#   {
#     'name': 'cis-centos7-level1',
#     'compliance': 'admin/cis-centos7-level1',
#   }
# )
