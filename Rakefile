# Cucumber task
require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
end

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

# API task. Lists methods, constants etc. that belong to the user API.
task :api do |t|
  puts "============================================="
  puts "The following objects belong to the user API."
  puts "For information on the APIs, see NEWS."
  puts "============================================="
  YARD::CLI::List.new.run("--query", "@api.text =~ /^user/")
end


# Debug task. Checks if I've forgotten a debug statement somewhere.
task :debug do |t|
  Dir['**/*.rb'].each do |f|
    File.open(File.join(File.dirname(__FILE__), f), 'r') do |file|
      ct = 1
      file.each do |line|
        fail("DEBUG in file #{f}, line #{ct}.\n#{line}") if line =~ /DEBUG/
        ct += 1
      end
    end
  end
end
