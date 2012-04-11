Given /^the following bibliography:$/ do |bib|
  @bib = bib
  @bib_file = File.join(TMPDIR, 'test.bib')

  File.open(@bib_file, 'w') do |f|
    f.write @bib
  end
end

Given /^the following style:$/ do |sty|
  @style = sty 
  @style_file = File.join(TMPDIR, 'test_style.rb')

  File.open(@style_file, 'w') do |f|
    f.write @style
  end
end

Then /^the result should be:$/ do |result|
  @result.should == result
end

Then /^the result should be "(.*)"/ do |result|
  @result.should == result
end
