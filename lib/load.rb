require 'lib/util.rb'
require 'lib/preconditions.rb'

Dir.glob("lib/deploy/*rb").each do |file|
  require file
end
