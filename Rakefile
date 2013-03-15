require 'lib/load.rb'

Update.update_to_latest

namespace :tag do
  desc "Display latest tag"
  task :latest, :repo do |t, args|
    repo = Util.get_arg(args, :repo)
    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} tag latest")
  end

  desc "Create a new tag on the /web/gilt repo; sends notifications"
  task :create, :repo, :major_minor_micro do |t, args|
    repo = Util.get_arg(args, :repo)
    increment = Util.get_optional_arg(args, :major_minor_micro) || 'micro'
    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} tag create #{increment}")
  end

end

namespace :release_branch do

  desc "Displays the current release branch, if any"
  task :current, :repo do |t, args|
    repo = Util.get_arg(args, :repo)
    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} release-branch current")
  end

  desc "Creates a new release branch - if there is an existing release branch, fails, otherwise will create a new branch and update setup that this is the new release branch"
  task :create, :repo, :branch do |t, args|
    repo = Util.get_arg(args, :repo)
    branch = Util.get_arg(args, :branch)
    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} release-branch create #{branch}")
  end

  desc "Clears the current release_branch"
  task :clear, :repo do |t, args|
    repo = Util.get_arg(args, :repo)
    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} release-branch clear")
  end

  desc "Merge source branch into master and publishing an announcement"
  task :merge, :repo, :source_branch do |t, args|
    repo = Util.get_arg(args, :repo)
    source_branch = Util.get_arg(args, :source_branch)

    if source_branch == "master"
      raise "Merging from source_branch master not supported. Other branches should rebase origin/master"
    end

    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} release-branch merge #{source_branch} master")
  end

end

namespace :deploy do

  desc "Deploy a specified tag to production"
  task :production, :repo, :tag do |t, args|
    repo = Util.get_arg(args, :repo)
    tag = Util.get_arg(args, :tag)
    class_name = "Deploy::#{repo.capitalize}"
    begin
      klass = eval(class_name)
    rescue Exception => e
      raise "Could not find class[#{class_name}]. If repo name is correct, the module should be defined in lib/deploy/#{repo}.rb"
    end
    klass.send(:deploy_production, tag)
  end

  desc "Deploys a specified repo/tag to staging by queuing that file for next integration release"
  task :integration, :repo, :tag do |t, args|
    repo = Util.get_arg(args, :repo)
    tag = Util.get_arg(args, :tag)
    Integration.new(repo).queue_for_integration(tag)
  end

end
