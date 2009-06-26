# @see http://reborg.tumblr.com/post/99668398/rails-gems-unpack-native

rake 'gems:build', :sudo => true

if File.exist?(".svn")
  
  run "svn propset svn:ignore '*.o' vendor/gems/nokogiri-1.2.3/ext/nokogiri"
  run "svn propset svn:ignore 'Makefile' vendor/gems/nokogiri-1.2.3/ext/nokogiri"
  run "svn propset svn:ignore '*' vendor/gems/nokogiri-1.2.3/ext/nokogiri/conftest.dSYM"
  run "svn propset svn:ignore 'native.bundle' vendor/gems/nokogiri-1.2.3/lib/nokogiri"

elsif File.exist?(".git")
  
  run("find . \\( -type d -empty \\) -and \\( -not "+
      "-regex ./\\.git.* \\) -exec touch {}/.gitignore \\;")
  file '.gitignore', <<-CODE
  vendor/gems/nokogiri-1.2.3/ext/nokogiri/Makefile
  vendor/gems/nokogiri-1.2.3/ext/nokogiri/conftest.dSYM/**/*
  vendor/gems/nokogiri-1.2.3/ext/nokogiri/*.o
  vendor/gems/nokogiri-1.2.3/lib/nokogiri/native.bundle
  CODE
  
end
