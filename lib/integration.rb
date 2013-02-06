# Utilities to work with integration environment
class Integration

  def initialize(repo)
    @repo = Preconditions.check_not_null(repo)
  end

  def queue_for_integration(tag)
    Preconditions.check_not_null(tag)
    dir = File.join(File.dirname(__FILE__), '..')
    Dir.chdir(dir) do
      if File.exists?("ioncannon-utils")
        Util.system_or_fail("cd ioncannon-utils && git checkout master && git pull --rebase origin master")
      else
        Util.system_or_fail("git clone ssh://gerrit.gilt.com:29418/ioncannon-utils.git")
      end
    end

    file = File.join(dir, "ioncannon-utils/bin/queue-for-integration")
    command = "%s --application %s --version %s" % [file, @repo, tag]
    Util.system_or_fail(command)
  end

end
