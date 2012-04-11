Given /^the following file:$/ do |file|
  @process_file_content = file
  @process_file = File.join(TMPDIR, 'testfile')

  File.open(@process_file, 'w') do |f|
    f.write @process_file_content 
  end
end

When /^I process the file$/ do
  @result = RCite::CLI::ProcessCommand.new.run(['-s', @style_file   ,
                                                '-b', @bib_file     ,
                                                      @process_file] )
end
