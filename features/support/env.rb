# SimpleCov Start 
# Note that the central SimpleCov configuration can be found in
# (project root)/.simplecov.
require 'simplecov'

# RSpec Setup

require 'rspec/expectations'

# Load Path Setup

$:.unshift(".")
require 'lib/rcite'

# HOOKS ########################################################################  
                                                                                
require 'fileutils'                                                             
                                                                                
TMPDIR = File.join(File.dirname(__FILE__), 'tmp').freeze                        
                                                                                
Before do                                                                       
  Dir.mkdir(TMPDIR)                                                             
end                                                                             
                                                                                
After do                                                                        
  FileUtils::rm_r(TMPDIR) if File.exist?(TMPDIR)                                
end
