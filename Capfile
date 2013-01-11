require 'lib/load.rb'

DIR = "/web/gilt"

set :gateway, '10.50.50.14'

role :rails_server, 'weba1', :primary => true
role :rails_server, 'weba2', 'weba3', 'web-rails1', 'web-rails2', 'web-rails3'
role :job_worker, 'job2', :primary => true
role :job_worker, 'job3'
role :warehouse_server, 'job3'

ALL_ROLES = [:rails_server, :job_worker, :warehouse_server]

namespace :production do

  task :deploy_with_gems do
    do_deploy(:gems => true)
  end

  task :deploy do
    do_deploy(ENV['TAG'])
  end

  task :deploy_latest do
    tag = Tag.new(DIR)
    do_deploy(tag.current)
  end

  def do_deploy(tag, opts={})
    if tag.to_s == ""
      raise "missing tag"
    end
    gems = opts.delete(:gems)

    run deploy_code_commands(tag).join(' && '), :roles => ALL_ROLES
    if gems
      run install_gems_commands.join(' && '), :roles => ALL_ROLES
    end

    run stop_jobs_commands(tag).join(' && '), :roles => [:job_worker]
    run stop_warehouse_commands.join(' && '), :roles => [:warehouse_server]
    run kill_jobs_commands.join(' && '), :roles => [:job_worker]
    run start_jobs_commands.join(' && '), :roles => [:job_worker]
    run start_warehouse_commands.join(' && '), :roles => [:warehouse_server]

    [[even_rails_servers], [odd_rails_servers]].each do |hosts|
      run stop_passenger_commands.join(' && '), :hosts => hosts
      run start_passenger_commands.join(' && '), :hosts => hosts
    end
  end

  def deploy_code_commands(tag)
    ['ulimit -n 10000',
     'umask 002',
     'cd /web/gilt',
     'sudo chmod -R g+w /web/gilt/.git',
     'git fetch',
     "git checkout -f #{tag}"
    ]
  end

  def install_gems_commands
    ["sudo chown -fR web:web #{webroot}/vendor",
     "sudo chmod -fR g+w #{webroot}/vendor",
     %Q{cd #{webroot} && sudo -u web CXX=g++ /usr/local/bin/gem bundle --only production}]
  end

  def stop_jobs_commands(tag)
    message = "Cancelled by deployment of #{tag}"
    ["sudo find /service -maxdepth 1 -name job_worker* | xargs sudo svc -d",
     "curl -X DELETE \"job3.prod.iad:8080/api/1/task/cancel/started?message=#{message}\""]
  end

  def kill_jobs_commands
    ["ps -ef | grep catwalk | grep -v grep | awk '{print \"sudo kill -9 \" $2}' | sh"]
  end

  def start_jobs_commands
    ["sudo find /service -maxdepth 1 -name job_worker* | xargs sudo svc -u"]
  end

  def stop_warehouse_commands
    ["sudo find /service -maxdepth 1 -name *thin* | xargs sudo svc -d"]
  end

  def start_warehouse_commands
    ["sudo find /service -maxdepth 1 -name *thin* | xargs sudo svc -u"]
  end

  def stop_passenger_commands
    ["sudo find /service -maxdepth 1 -name httpd* | xargs sudo svc -d",
     "sudo find /service -maxdepth 1 -name *_thin* | xargs sudo svc -d"]
  end

  def start_passenger_commands
    ["sudo find /service -maxdepth 1 -name httpd* | xargs sudo svc -u",
     "sudo find /service -maxdepth 1 -name *_thin* | xargs sudo svc -u"]
  end

  def even_rails_servers
    select_rails_servers(0)
  end

  def odd_rails_servers
    select_rails_servers(1)
  end

  def select_rails_servers(target_index)
    servers = []
    find_servers(:roles => [:rails_server]).each_with_index do |host, index|
      if index % 2 == target_index
        servers << host
      end
    end
    servers
  end

end
