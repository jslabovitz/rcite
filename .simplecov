# Central SimpleCov configuration for Cucumber and rspec.

SimpleCov.at_exit do
  SimpleCov.result.format!
  File.open(File.join(SimpleCov.coverage_path, 'percentage.txt'), 'w') do |f|
    f.write(SimpleCov.result.covered_percent)
  end
end

SimpleCov.start do
  add_filter 'styles/'
  add_filter 'spec/'
  add_filter 'features/'
  add_filter 'lib/rcite/style_options.rb'
end
