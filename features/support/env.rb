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
