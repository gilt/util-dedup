module Util

  def Util.system_or_fail(command)
    puts command
    result = system(command)
    Preconditions.check_state(result, "Command failed - result code[%s]: %s" % [result, command])
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

  def Util.get_arg(args, name)
    value = args[name]
    if value.nil? || value.strip == ""
      raise "Argument named[#{name}] cannot be empty. args[#{args.inspect}]"
    end
    value
  end

  def Util.ask_to_execute(dir, commands, &block)
    puts "About to execute in dir[%s]:" % [dir]
    puts "  " << commands.join("\n  ")
    print "Continue? (y/n) "

    continue = STDIN.gets.strip
    if continue.split('').first.to_s.downcase == "y"
      Dir.chdir(dir) do
        commands.each do |command|
          Util.system_or_fail(command)
        end
      end

      if block_given?
        block.call
      end
    end
  end
end
