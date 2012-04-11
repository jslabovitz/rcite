Given /^the following bibliography:$/ do |bib|
  @bib_file = File.join(TMPDIR, 'test.bib')

  File.open(@bib_file, 'w') do |f|
    f.write bib
  end
end

Given /^the following style:$/ do |sty|
  @style_file = File.join(TMPDIR, 'test_style.rb')

  File.open(@style_file, 'w') do |f|
    f.write sty
  end
end

Given /^the following addition to the style:$/ do |sty_add|
  File.open(@style_file, 'a') do |f|
    f.puts
    f.write sty_add
  end
end

Then /^the result should be:$/ do |result|
  @result.should == result
end

Then /^the result should be "(.*)"/ do |result|
  @result.should == result
end
