require 'lib/load.rb'

current_user = `whoami`.strip

def run(command)
  puts command
  if !system(command)
    raise "Command failed with invalid response code: #{command}"
  end
end

desc "Creates a new release branch - if there is an existing release branch, fails, otherwise will create a new branch and update setup that this is the new release branch"
task :create_release_branch, :repo, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} create_release_branch #{branch}")
end

desc "Create a new tag on the /web/gilt repo; sends notifications"
task :tag, :repo, :major_minor_micro do |t, args|
  repo = Util.get_arg(args, :repo)
  increment = Util.get_optional_arg(args, :major_minor_micro) || 'micro'
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} tag create #{increment}")
end

desc "Merge source branch into other, publishing announcement if dest_branch is master"
task :merge, :repo, :source_branch, :dest_branch do |t, args|
  repo = Util.get_arg(args, :repo)
  branch = Util.get_arg(args, :branch)
  raise 'NOT DONE'
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} release_owner merge #{branch}")
end

desc "cherrypick a single ref to the specified branch"
task :cherrypick, :repo, :ref, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  ref = Util.get_arg(args, :ref )
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} cherry-pick %s %s" % [ref, branch])
end

desc "Create a new tag in repo, send notifications"
task :deploy, :env, :repo, :tag do |t, args|
  env = Util.get_arg(args, :env)
  repo = Util.get_arg(args, :repo)
  tag = Util.get_arg(args, :tag)
  dir = "/web/#{repo}"
  if !Tag.new(dir).exists?(tag)
    puts "ERROR: Tag[%s] not found" % [tag]
    exit(1)
  end
  class_name = "Deploy::#{repo.capitalize}"
  begin
    klass = eval(class_name)
  rescue Exception => e
    raise "Could not find class[#{class_name}]. If repo name is correct, the module should be defined in lib/deploy/"
  end
  klass.send(:deploy, env, tag)
end
