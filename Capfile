require 'lib/load.rb'

set :gateway, '10.50.50.14'

role :warehouse_server, 'job3'
role :job_worker, 'job2', 'job3'
role :rails_server, 'weba1', 'weba2', 'weba3', 'web-rails1', 'web-rails2', 'web-rails3'

ALL_ROLES = [:rails_server, :job_worker, :warehouse_server]

namespace :production do

  task :deploy_with_gems do
    Deploy.new(self, ENV['TAG'].to_s, :gems => true).run
  end

  task :deploy do
    Deploy.new(self, ENV['TAG'].to_s).run
  end

end

class Deploy

  def initialize(cap, tag, opts={})
    @cap = Preconditions.check_not_null(cap)
    @tag = tag
    Preconditions.check_argument(tag.to_s != "", "missing TAG environment variable")
    @gems = opts.delete(:gems) ? true : false
    Preconditions.check_state(opts.empty?, "Invalid opts: #{opts.inspect}")
  end

  def run
    commands = Commands.new(@cap, @tag)
    commands.run :deploy_code, :roles => ALL_ROLES

    if @gems
      commands.run :install_gems, :roles => ALL_ROLES
    end

    threads = []
    threads << Thread.new do
      commands.run :stop_jobs, :roles => [:job_worker]
      commands.run :start_jobs, :roles => [:job_worker]
    end

    threads << Thread.new do
      commands.run :stop_warehouse, :roles => [:warehouse_server]
      commands.run :start_warehouse, :roles => [:warehouse_server]
    end

    threads << Thread.new do
      all_hosts = @cap.find_servers(:roles => [:rails_server]).map(&:host).sort
      HostSplitter.new(all_hosts).each do |hosts|
        commands.run :stop_passenger, :hosts => hosts
        commands.run :start_passenger, :hosts => hosts
        # a second to let zeus pool bring back the nodes we just restartd
        sleep 5
      end
    end

    threads.each { |t| t.join }
  end

  # Takes a list of hosts and splits into two lists, as even as
  # possible
  class HostSplitter

    def initialize(hosts)
      @hosts = hosts
    end

    def each
      yield select(0)
      yield select(1)
    end

    private
    def select(target_index)
      servers = []
      @hosts.each_with_index do |host, index|
        if index % 2 == target_index
          servers << host
        end
      end
      servers
    end
  end

  class Commands

    def initialize(cap, tag)
      @cap = Preconditions.check_not_null(cap)
      @tag = Preconditions.check_not_null(tag)
    end

    def run(command_name, opts={})
      params = {}
      if roles = opts.delete(:roles)
        params[:roles] = roles
      end
      if hosts = opts.delete(:hosts)
        params[:hosts] = hosts
      end
      Preconditions.check_state(opts.empty?, "Invalid opts: #{opts.inspect}")

      commands = self.send(command_name)
      @cap.run commands.join(' && '), params
    end

    private

    def deploy_code
      ['ulimit -n 10000',
       'umask 002',
       'cd /web/gilt',
       'sudo chmod -R g+w /web/gilt/.git',
       'git fetch',
       "git checkout -f #{@tag}"
      ]
    end

    def install_gems
      ["sudo chown -fR web:web #{webroot}/vendor",
       "sudo chmod -fR g+w #{webroot}/vendor",
       %Q{cd #{webroot} && sudo -u web CXX=g++ /usr/local/bin/gem bundle --only production}]
    end

    def stop_jobs
      message = "Cancelled by deployment of #{@tag}"
      ["sudo find /service -maxdepth 1 -name job_worker* | xargs sudo svc -d",
       "curl -X DELETE \"job3.prod.iad:8080/api/1/task/cancel/started?message=#{message}\"",
       "sleep 1",
       kill("catwalk")]
    end

    def start_jobs
      ["sudo find /service -maxdepth 1 -name job_worker* | xargs sudo svc -u"]
    end

    def stop_warehouse
      ["sudo find /service -maxdepth 1 -name *thin* | xargs sudo svc -d",
       "sleep 1",
       kill("thin")]
    end

    def start_warehouse
      ["sudo find /service -maxdepth 1 -name *thin* | xargs sudo svc -u"]
    end

    def stop_passenger
      ["sudo find /service -maxdepth 1 -name httpd* | xargs sudo svc -d",
       "sudo find /service -maxdepth 1 -name *_thin* | xargs sudo svc -d",
       "sleep 1",
       kill("httpd"),
       kill("thin")]
    end

    def start_passenger
      ["sudo find /service -maxdepth 1 -name httpd* | xargs sudo svc -u",
       "sudo find /service -maxdepth 1 -name *_thin* | xargs sudo svc -u",
       "sleep 5",
       "curl --silent 'http://localhost/system/ping'"]
    end

    private
    def kill(name)
      "ps -ef | grep #{name} | grep -v grep | awk '{print \"sudo kill -9 \" $2}' | sh"
    end

  end

end
