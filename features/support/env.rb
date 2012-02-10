# SimpleCov Configuration
require 'simplecov'

SimpleCov.at_exit do
  SimpleCov.result.format!
  File.open(File.join(SimpleCov.coverage_path, 'percentage.txt'), 'w') do |f|
    f.write(SimpleCov.result.covered_percent)
  end
end

SimpleCov.configure do
  add_filter 'styles/'
end

SimpleCov.start

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
