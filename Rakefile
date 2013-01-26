require 'lib/load.rb'

DIR = "/web/gilt"
POTENTIAL_DEPLOY_MASTERS = %w(ssmith mbryzek khyland rmartin).sort
BRANCHES_FOR_YAMMER = %w(master integration)
MASTER = 'master'

current_user = `whoami`.strip

def run(command)
  puts command
  if !system(command)
    raise "Command failed with invalid response code: #{command}"
  end
end

task :create_release_branch, :branch do |t, args|
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb gilt create_release_branch #{branch}")
end

desc "Create a new tag on the /web/gilt repo; sends notifications"
task :tag do
  run("/web/util-install/bin/util_deploy.rb gilt tag")
end

desc "merge a branch to master, tag, and deploy to production"
task :merge_and_deploy_to_production, :branch do |t, args|
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb gilt release_owner merge #{branch}")
end

desc "cherrypick a single ref to the specified branch"
task :cherrypick, :ref, :branch do |t, args|
  ref = Util.get_arg(args, :ref )
  branch = Util.get_arg(args, :branch)
  run("/web/util-install/bin/util_deploy.rb gilt cherry-pick %s %s" % [ref, branch])
end

desc "deploy the latest tag to production"
task :deploy_latest_to_production do
  tag = Tag.new(DIR)
  Rake::Task['deploy_to_production'].invoke(tag.current)
end

desc "Deploy a specific tag to production"
task :deploy_to_production, :tag do |t, args|
  tag = Util.get_arg(args, :tag)

  if !Tag.new(DIR).exists?(tag)
    puts "ERROR: Tag[%s] not found" % [tag]
    exit(1)
  end

  puts "Rails deploy starting. You need to manually post into the Skype chat room Gilt US Production"
  puts "   rails %s to prod" % [tag]
  if !Util.ask_boolean("Continue?")
    exit(0)
  end

  Util.system_or_fail("export TAG=%s && cap production:deploy" % [tag])

  if ScmsVersion.verify_single_scms_version("http://www.gilt.com")
    message = "completed production deploy of rails version %s" % [tag]
    puts message
  end

end
