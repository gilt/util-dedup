module Util

  def Util.system_or_fail(command)
    puts command
    Preconditions.check_state(system(command), "Command failed: #{command}")
  end

end
