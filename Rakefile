require 'lib/util.rb'
require 'lib/preconditions.rb'
require 'lib/yammer.rb'
Dir.glob("tasks/*rb").each { |f| require f }

DIR = "/web/gilt"

current_user = `whoami`.strip

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
      `git diff #{current_tag}`
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
  yammer.message_create!("starting production deploy of rails version %s" % [tag])

  Util.system_or_fail("export TAG=%s && cd %s && cap iad:deploy" % [tag, DIR])

  Util.with_exception_log do
    yammer.message_create!("completed production deploy of rails version %s" % [tag])
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
