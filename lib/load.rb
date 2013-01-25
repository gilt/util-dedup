require 'lib/util.rb'
require 'lib/preconditions.rb'
require 'lib/scms_version.rb'
require 'lib/yammer.rb'
Dir.glob("tasks/*rb").each { |f| require f }
