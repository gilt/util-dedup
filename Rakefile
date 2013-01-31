require 'lib/load.rb'

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

  desc "Merge source branch into other, publishing announcement if dest_branch is master"
  task :merge, :repo, :source_branch, :target_branch do |t, args|
    repo = Util.get_arg(args, :repo)
    source_branch = Util.get_arg(args, :source_branch)
    target_branch = Util.get_arg(args, :target_branch)

    if target_branch != "master"
      raise "Merging is currently only supported to master. Other branches should rebase origin/master"
    end

    if source_branch == "master"
      raise "Merging from source_branch master not supported. Other branches should rebase origin/master"
    end

    Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} release-branch merge #{source_branch} #{target_branch}")
  end

end

desc "cherrypick a single ref to the specified branch"
task :cherrypick, :repo, :ref, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  ref = Util.get_arg(args, :ref )
  branch = Util.get_arg(args, :branch)
  Util.system_or_fail("/web/svc-software-install/bin/deploy.rb '#{Util.current_user}' #{repo} cherry-pick %s %s" % [ref, branch])
end

desc "Create a new tag in repo, send notifications"
task :deploy, :env, :repo, :tag do |t, args|
  env = Util.get_arg(args, :env)
  repo = Util.get_arg(args, :repo)
  tag = Util.get_arg(args, :tag)
  dir = "/web/#{repo}"
  class_name = "Deploy::#{repo.capitalize}"
  begin
    klass = eval(class_name)
  rescue Exception => e
    raise "Could not find class[#{class_name}]. If repo name is correct, the module should be defined in lib/deploy/"
  end
  klass.send(:deploy, env, tag)
end
