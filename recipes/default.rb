#
# Cookbook Name:: cachet
# Recipe:: default
#
# Copyright (c) 2015 Benjamin Chrobot, All Rights Reserved.

# include_recipe 'ssl'
include_recipe 'git'
include_recipe 'nodejs'
include_recipe 'composer'

# Configure web hosting service
if node['cachet']['server']['provider'] == "apache"
  # Configure Apache
  include_recipe 'apache2::mod_ssl'
  include_recipe 'php'

elsif node['cachet']['server']['provider'] == "nginx"
  # Configure nginx
  include_recipe 'nginx'
  include_recipe 'php-fpm'
end

# Clone cachet project
script "clone_cachet" do
  user "root"
  cwd "/var/www"
  code "git clone https://github.com/cachethq/Cachet.git cachet"
end

# Install Node dependencies
nodejs_npm 'bower'
nodejs_npm 'gulp'

script "install_dependencies" do
  user "root"
  cwd "#{node['cachet']['docroot']}/cachet"
  code <<-EOH
  npm install
  bower install
  gulp
  EOH
end

# Configure database provider
if node['cachet']['database']['provider'] == "mysql"
  # Configure MySQL service
  mysql_service 'default' do
    port '3306'
    version '5.5'
    initial_root_password node['mysql']['server_root_password']
    action [:create, :start]
  end
  mysql2_chef_gem 'default' do
    action :install
  end

  # MySQL root connection
  mysql_connection_info = {:host => "127.0.0.1",
                         :username => 'root',
                         :password => node['mysql']['server_root_password']}

  # Create MySQL database
  mysql_database node['cachet']['database']['dbname'] do
    connection mysql_connection_info
    action :create
  end

  # Create MySQL user
  mysql_database_user node['cachet']['database']['username'] do
    connection mysql_connection_info
    password node['cachet']['database']['password']
    action :create
  end

  # Grant database privileges
  mysql_database_user node['cachet']['database']['username'] do
    connection mysql_connection_info
    database_name node['cachet']['database']['dbname']
    privileges [:all]
    action :grant
  end
end

# Change the application key which is used for encryption
script "install_composer_dependencies" do
  user "root"
  cwd "#{node['cachet']['docroot']}/cachet"
  code "composer install --no-dev -o"
end

# Configure Cachet database connection
template "#{node['cachet']['docroot']}/cachet/.env.php" do
  source 'database.php.erb'
end

# Change the application key which is used for encryption
script "configure_cachet" do
  user "root"
  cwd "#{node['cachet']['docroot']}/cachet"
  code <<-EOH
  php artisan key:generate
  php artisan migrate
  php artisan db:seed
  EOH
end

# Enable site
if node['cachet']['server']['provider'] == "apache"
  # Enable Cachet virtual host
  web_app "cachet" do
    server_name node['hostname']
    server_aliases [node['fqdn'], node['cachet']['server_aliases']].flatten.join " "
    docroot "#{node['cachet']['docroot']}/cachet/public"
    cookbook 'apache2'
  end

elsif node['cachet']['server']['provider'] == "nginx"
  # Enable Cachet site
  template '/etc/sites-available/cachet.conf' do
    source 'cachet-nginx.conf.erb'
    notifies :run, "script[enable-nginx-site]"
    notifies :restart, 'service[nginx]'
  end
end

# Enable nginx site (waits for nginx template)
script "enable-nginx-site" do
  user "root"
  code "nxensite cachet-nginx.conf"
  action :nothing
end