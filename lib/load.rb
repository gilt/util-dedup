require 'lib/util.rb'
require 'lib/preconditions.rb'
require 'lib/tag.rb'

Dir.glob("lib/deploy/*rb").each do |file|
  require file
end
