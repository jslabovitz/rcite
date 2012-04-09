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
