# RSpec task
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# YARD task
require 'yard'
YARD::Rake::YardocTask.new(:doc)

# Coverage task. Checks if code coverage is 100%.
task :cov do |t|
  PERCENTAGE_FILE = File.join(File.dirname(__FILE__), 'coverage/percentage.txt')
  if !File.exists?(PERCENTAGE_FILE)
    fail "Could not find file 'coverage/percentage.txt'. Please run 'rake spec'"+
      " to generate coverage statistics."
  end

  File.open(PERCENTAGE_FILE, 'r') do |f|
    if f.read.to_f != 100.0
      fail "Code coverage is below 100%. See coverage/index.html for details."
    end
  end
end
