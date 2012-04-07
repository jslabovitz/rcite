# Load path
$: << './lib/'
$: << './lib/rcite/'
$: << './styles/'

# SimpleCov start
# Note that the central SimpleCov configuration can be found in
# (project root)/.simplecov.
require 'simplecov'

# Helper methods
def spec_text(text, result)
  @pro.cite(text).should == result
end
