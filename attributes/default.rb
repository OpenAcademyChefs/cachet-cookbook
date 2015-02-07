#
# Cookbook Name:: cachet
# Recipe:: default
# Attributes:: default
#
# Copyright (c) 2015 Benjamin Chrobot, All Rights Reserved.

default['cachet']['environment'] = 'production'
default['cachet']['server_aliases'] = []
default['cachet']['docroot'] = '/var/www'
default['cachet']['server']['provider'] = 'apache'
default['cachet']['database']['provider'] = 'mysql'
default['cachet']['database']['dbname'] = 'cachet'
default['cachet']['database']['username'] = 'cachet'
default['cachet']['database']['password'] = 'ch4ngeM3'

default['mysql']['server_root_password'] = 'ch4ngeM3'