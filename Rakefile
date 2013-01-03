Dir.glob("lib/*rb").each { |f| require f }
Dir.glob("tasks/*rb").each { |f| require f }

DIR = "/web/gilt"

task :tag do
  Dir.chdir(DIR) do
    Util.system_or_fail("git checkout master")
    Util.system_or_fail("git pull --rebase")
  end

  tag = Tag.new(DIR)
  current_tag = tag.current

  diff = Dir.chdir(DIR) do
    `git diff #{current_tag}`
  end.strip

  if diff == ""
    puts "Nothing has changed since tag[#{current_tag}]"
  else
    new_tag = tag.next
    puts "current_tag[%s]. Creating tag[%s]" % [current_tag, new_tag]
    Dir.chdir(DIR) do
      Util.system_or_fail("git tag -a -m '#{new_tag}' #{new_tag}")
      Util.system_or_fail("git push --tags origin")
    end
    Util.system_or_fail("build/bin/gilt-send-changelog-email.rb gilt #{current_tag} #{new_tag}")
  end

end
