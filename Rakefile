require 'lib/util.rb'
require 'lib/preconditions.rb'
require 'lib/yammer.rb'
Dir.glob("tasks/*rb").each { |f| require f }

DIR = "/web/gilt"
POTENTIAL_DEPLOY_MASTERS = %w(ssmith mbryzek khyland rmartin).sort
BRANCHES_FOR_YAMMER = %w(master integration)

current_user = `whoami`.strip

task :yammer_test_post do
  Util.with_trace do
    yammer = Yammer.new(current_user)
    yammer.message_create!("Test from %s" % [current_user])
  end
end

task :set_deploy_master do
  Util.with_trace do
    yammer = Yammer.new(current_user)

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
    yammer.message_create!("The deploy master is now #{master}", :topics => ['DeployMaster'])
  end
end

task :yammer_configure do
  Util.with_trace do
    puts "Current user is %s" % [current_user]
    if token = Yammer::AccessToken.get_for_username(current_user)
      puts "Your yammer token is: #{token}"
    else
      puts "You do not have a yammer token yet. To get one:"
      puts "  1. In a browser, goto "
      puts "     #{Yammer::GET_TOKEN_URL}"
      puts "After you authenticate, you will be redirected to a URL that contains a"
      puts "URL parameter access_token."
      puts ""
      while true
        puts "Enter the token value here: "
        token = STDIN.gets.strip
        if Yammer::AccessToken.is_token_valid?(token)
          Yammer::AccessToken.set_for_username!(current_user, token)
          break
        else
          puts "*** Invalid token"
        end
      end
    end
  end
end

task :tag do
  Util.with_trace do
    pwd = `pwd`.strip
    yammer = Yammer.new(current_user)

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
          yammer.message_create!("Rails #{new_tag} created")
          # TODO: Validate that this works with large messages"
          yammer.message_create!("Diff in version #{new_tag}:\n#{diff}")
        end
        Util.with_exception_log do
          Util.system_or_fail("#{pwd}/build/bin/gilt-send-changelog-email.rb gilt #{current_tag} #{new_tag}")
        end
      end
    end
  end
end

task :deploy_production, :tag do |t, args|
  tag = Util.get_arg(args, :tag)

  if !Tag.new(DIR).exists?(tag)
    puts "ERROR: Tag[%s] not found" % [tag]
    exit(1)
  end

  yammer = Yammer.new(current_user)
  yammer.message_create!("starting production deploy of rails version %s" % [tag], :topics => ['ProductionDeploy'])

  Util.system_or_fail("export TAG=%s && cd %s && cap iad:deploy" % [tag, DIR])

  Util.with_exception_log do
    yammer.message_create!("completed production deploy of rails version %s" % [tag], :topics => ['ProductionDeploy'])
  end

  puts "Rails deploy complete. You still need to:"
  puts ""
  puts "1. Post in Skype chat room Gilt US Production"
  puts "   rails %s to prod" % [tag]
  puts ""
  puts "2. Goto https://admin.gilt.com/admin/dev/monitor and make sure"
  puts "   there is only 1 version of rails"
  puts ""

end

task :merge, :source, :destination do |t, args|
  source = Util.get_arg(args, :source)
  destination = Util.get_arg(args, :destination)
  yammer = Yammer.new(current_user)

  commands = []
  commands << "git checkout #{source}"
  commands << "git pull --rebase"
  commands << "git checkout #{destination}"
  commands << "git pull --rebase"
  commands << "git merge #{source}"
  commands << "git push origin #{destination}"

  puts "About to execute in dir[%s]:" % [DIR]
  puts "  " << commands.join("\n  ")
  print "Continue? (y/n) "

  continue = STDIN.gets.strip
  if continue.split('').first.to_s.downcase == "y"
    Dir.chdir(DIR) do
      commands.each do |command|
        Util.system_or_fail(command)
      end
    end
    if BRANCHES_FOR_YAMMER.include?(destination)
      yammer.message_create!("merged gilt repo: #{source} -> #{destination}")
    end
  end

end
