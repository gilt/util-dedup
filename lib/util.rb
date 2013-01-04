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

end
