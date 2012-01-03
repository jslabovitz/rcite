# Specs concerned with the bibtex-ruby library

require 'spec_helper'
require 'yaml'
require 'bibtex'
require 'rspec/expectations'

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
    bib.to_a.should == YAML.load(yaml).to_a
  end
end

describe BibTeX do
  describe "#parse" do
    it "should turn a multiline value into one line" do
      entry = """
        @article{article1,
          title = {A
                   multiline
                   value}
        }
      """

      BibTeX.parse(entry)['article1']['title'].should == "A multiline value"
    end

    it "should throw an appropriate error when a BibTeX file is not parseable" do
      entry = "END
        @article{article1
          title = {Not parseable because no comma after article1}
        }
      "

      BibTeX.log.level = Logger::FATAL # suppresses annoying error message
      expect { BibTeX.parse(entry) }.to raise_error BibTeX::ParseError
    end
  end
end
