module Util

  def Util.system_or_fail(command)
    puts command
    Preconditions.check_state(system(command), "Command failed: #{command}")
  end

  def Util.with_trace
    yield
  rescue Exception => e
    msg = Kernel.caller.reverse.join("\n")
    msg << "\n\nERROR: " << e.to_s
    raise msg
  end

  def Util.with_tempfile
    tmp = Tempfile.new('util-rails-deploy-yammer')
    begin
      yield tmp.path
    ensure
      if File.exists?(tmp.path)
        File.delete(tmp.path)
      end
    end
  end

  def Util.with_exception_log
    yield
  rescue Exception => e
    puts Kernel.caller.first
    puts "ERROR: #{e.to_s}"
  end

end
