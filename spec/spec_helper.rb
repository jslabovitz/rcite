# Load path
$: << './lib/rcite/'

# SimpleCov configuration
require 'simplecov'

SimpleCov.at_exit do
  SimpleCov.result.format!
  File.open(File.join(SimpleCov.coverage_path, 'percentage.txt'), 'w') do |f|
    f.write(SimpleCov.result.covered_percent)
  end
end

SimpleCov.start
