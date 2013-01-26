require 'lib/load.rb'

current_user = `whoami`.strip

def run(command)
  puts command
  if !system(command)
    raise "Command failed with invalid response code: #{command}"
  end
end

task :create_release_branch, :repo, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} create_release_branch #{branch}")
end

desc "Create a new tag on the /web/gilt repo; sends notifications"
task :tag, :repo do |t, args|
  repo = Util.get_arg(args, :repo)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} tag")
end

desc "merge a branch to master, tag, and deploy to production"
task :merge_and_deploy_to_production, :repo, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} release_owner merge #{branch}")
end

desc "cherrypick a single ref to the specified branch"
task :cherrypick, :repo, :ref, :branch do |t, args|
  repo = Util.get_arg(args, :repo)
  ref = Util.get_arg(args, :ref )
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb '#{current_user}' #{repo} cherry-pick %s %s" % [ref, branch])
end

desc "Deploy a specific tag to production"
task :deploy_to_production, :repo, :tag do |t, args|
  repo = Util.get_arg(args, :repo)
  tag = Util.get_arg(args, :tag)
  dir = "/web/#{repo}"
  if !Tag.new(dir).exists?(tag)
    puts "ERROR: Tag[%s] not found" % [tag]
    exit(1)
  end
  raise 's'
  class_name = "Deploy::#{repo.capitalize}"
  begin
    klass = eval(class_name)
  rescue Exception => e
    raise "Could not find class[#{class_name}]. If repo name is correct, the module should be defined in lib/deploy/"
  end
  klass.send(:deploy_to_production, tag)

end
