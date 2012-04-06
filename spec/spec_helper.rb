# Load path
$: << './lib/'
$: << './lib/rcite/'
$: << './styles/'

# SimpleCov start
require 'simplecov'

# Helper methods
def spec_text(text, result)
  @pro.cite(text).should == result
end
