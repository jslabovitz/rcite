require 'spec_helper'
require 'yaml'
require 'bibtex'

ALL_TYPES_BIB_FILE = 'spec/files/all_types.bib'
ALL_TYPES_YML_FILE = 'spec/files/all_types.yml'

# This spec exists solely to ensure that there are no API changes
# in bibtex-ruby that I don't realize.

describe "The translation from bib to hash" do
  it "should be persistent" do
    bib = BibTeX::Bibliography.open(ALL_TYPES_BIB_FILE)
    yaml = ""
    File.open(ALL_TYPES_YML_FILE, "r") do |f|
      f.each { yaml << f.read }
    end
    bib.to_citeproc.should == YAML.load(yaml).to_a
  end
end
