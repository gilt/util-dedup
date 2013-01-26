require 'lib/load.rb'

DIR = "/web/gilt"
POTENTIAL_DEPLOY_MASTERS = %w(ssmith mbryzek khyland rmartin).sort
BRANCHES_FOR_YAMMER = %w(master integration)
MASTER = 'master'

current_user = `whoami`.strip

task :set_deploy_master do
  Util.with_trace do
    POTENTIAL_DEPLOY_MASTERS.each_with_index do |name, index|
      puts "#{index + 1}. #{name}"
    end
    master = nil
    while master.nil?
      print "Who is new master (1-#{POTENTIAL_DEPLOY_MASTERS.size})? "
      index = STDIN.gets.strip.to_i - 1
      if index >= 0
        master = POTENTIAL_DEPLOY_MASTERS[index]
        if master.nil?
          puts "Invalid choice"
        end
      end
    end
    puts "Setting deploy master to %s" % [master]
  end
end

task :tag do
  Util.with_trace do
    pwd = `pwd`.strip

    Dir.chdir(DIR) do
      Util.system_or_fail("git checkout master")
      Util.system_or_fail("git pull --rebase")
    end

    tag = Tag.new(DIR)
    current_tag = tag.current
    new_tag = tag.next

    diff = Dir.chdir(DIR) do
      `git log --pretty=format:'%h : %s' #{current_tag}..master`
    end.strip

    if diff == ""
      puts "Nothing has changed since tag[#{current_tag}]"
    else
      puts "current_tag[%s]. Creating tag[%s]" % [current_tag, new_tag]
      Dir.chdir(DIR) do
        Util.system_or_fail("git tag -a -m '#{new_tag}' #{new_tag}")
        Util.system_or_fail("git push --tags origin")
        Util.with_exception_log do
          Util.system_or_fail("#{pwd}/build/bin/gilt-send-changelog-email.rb gilt #{current_tag} #{new_tag}")
        end
      end
    end
  end
end

task :merge_and_deploy_to_production, :branch do |t, args|
  branch = Util.get_arg(args, :branch)

  commands = []
  if branch != MASTER
    commands << "rake merge[%s,%s]" % [branch, MASTER]
  end
  commands << "rake tag"
  commands << "rake deploy_latest_to_production"
  if branch != MASTER
    commands << "rake merge[%s,%s]" % [MASTER, branch]
  end
  commands << "rake set_deploy_master"

  Util.ask_to_execute(DIR, commands)
end

task :deploy_latest_to_production do
  tag = Tag.new(DIR)
  Rake::Task['deploy_to_production'].invoke(tag.current)
end

task :deploy_to_production, :tag do |t, args|
  tag = Util.get_arg(args, :tag)

  if !Tag.new(DIR).exists?(tag)
    puts "ERROR: Tag[%s] not found" % [tag]
    exit(1)
  end


  puts "Rails deploy starting. Post Skype chat room Gilt US Production"
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

task :cherrypick, :ref, :branch do |t, args|
  ref = Util.get_arg(args, :ref )
  branch = Util.get_arg(args, :branch)

  commands = []
  commands << "git fetch"
  commands << "git checkout #{branch}"
  commands << "git pull --rebase"
  commands << "git cherry-pick -x #{ref}"
  commands << "git push origin #{branch}"

  Util.ask_to_execute(DIR, commands)
end

task :merge, :source, :destination do |t, args|
  source = Util.get_arg(args, :source)
  destination = Util.get_arg(args, :destination)

  commands = []
  commands << "git checkout #{source}"
  commands << "git pull --rebase"
  commands << "git checkout #{destination}"
  commands << "git pull --rebase"
  commands << "git merge #{source}"
  commands << "git push origin #{destination}"

  Util.ask_to_execute(DIR, commands)
end
