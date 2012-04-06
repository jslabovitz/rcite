# Load path
$: << './lib/'
$: << './lib/rcite/'
$: << './styles/'

# SimpleCov configuration
require 'simplecov'

SimpleCov.at_exit do
  SimpleCov.result.format!
  File.open(File.join(SimpleCov.coverage_path, 'percentage.txt'), 'w') do |f|
    f.write(SimpleCov.result.covered_percent)
  end
end

SimpleCov.configure do
  add_filter 'styles/'
  add_filter 'spec/'
end

SimpleCov.start

def spec_text(text, result)
  @pro.cite(text).should == result
end
