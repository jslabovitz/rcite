# Load path
$: << './lib/'
$: << './styles/'

# SimpleCov start
# Note that the central SimpleCov configuration can be found in
# (project root)/.simplecov.
require 'simplecov'

# Require whole gem
require 'rcite'

# Helper methods
def spec_text(text, result)
  @pro.cite(text).should == result
end

# Hooks

# The following hook 'unloads' styles that are loaded by specs multiple times.
# If your spec(s) need(s) to repeatedly load a style, please add it here.
RSpec.configure do |config|
  config.after :each do
    RCite.send(:remove_const, :ValidStyle) if RCite.const_defined? :ValidStyle
  end
end
