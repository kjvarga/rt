@spec = Gem::Specification.new do |s|
  s.name = "rack"
  s.rubyforge_project = 'rack'
  s.version = "1.0.0"
  s.summary = "a modular Ruby webserver interface"
  s.description = s.summary
  s.author = "Karl Varga"
  s.email = "kjvarga@gmail.com"
  s.homepage = "http://github.com/kjvarga/rack"
  
  s.extra_rdoc_files = %w[README.rdoc KNOWN-ISSUES.rdoc]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.0.0'
  
  s.executables = %w[]
  
  # = MANIFEST =
  s.files = %w(
Manifest
bin/rackup
contrib/rack_logo.svg
COPYING
KNOWN-ISSUES.rdoc
lib/rack/adapter/camping.rb
lib/rack/auth/abstract/handler.rb
lib/rack/auth/abstract/request.rb
lib/rack/auth/basic.rb
lib/rack/auth/digest/md5.rb
lib/rack/auth/digest/nonce.rb
lib/rack/auth/digest/params.rb
lib/rack/auth/digest/request.rb
lib/rack/auth/openid.rb
lib/rack/builder.rb
lib/rack/cascade.rb
lib/rack/chunked.rb
lib/rack/commonlogger.rb
lib/rack/conditionalget.rb
lib/rack/content_length.rb
lib/rack/content_type.rb
lib/rack/deflater.rb
lib/rack/directory.rb
lib/rack/file.rb
lib/rack/handler/cgi.rb
lib/rack/handler/evented_mongrel.rb
lib/rack/handler/fastcgi.rb
lib/rack/handler/lsws.rb
lib/rack/handler/mongrel.rb
lib/rack/handler/scgi.rb
lib/rack/handler/swiftiplied_mongrel.rb
lib/rack/handler/thin.rb
lib/rack/handler/webrick.rb
lib/rack/handler.rb
lib/rack/head.rb
lib/rack/lint.rb
lib/rack/lobster.rb
lib/rack/lock.rb
lib/rack/methodoverride.rb
lib/rack/mime.rb
lib/rack/mock.rb
lib/rack/recursive.rb
lib/rack/reloader.rb
lib/rack/request.rb
lib/rack/response.rb
lib/rack/rewindable_input.rb
lib/rack/session/abstract
lib/rack/session/abstract/id.rb
lib/rack/session/cookie.rb
lib/rack/session/memcache.rb
lib/rack/session/pool.rb
lib/rack/showexceptions.rb
lib/rack/showstatus.rb
lib/rack/static.rb
lib/rack/urlmap.rb
lib/rack/utils.rb
lib/rack.rb
rack.gemspec
Rakefile
README.rdoc
test/cgi
test/cgi/lighttpd.conf
test/cgi/test
test/cgi/test.fcgi
test/cgi/test.ru
test/multipart
test/multipart/binary
test/multipart/empty
test/multipart/file1.txt
test/multipart/ie
test/multipart/nested
test/multipart/none
test/multipart/text
test/spec_rack_auth_basic.rb
test/spec_rack_auth_digest.rb
test/spec_rack_auth_openid.rb
test/spec_rack_builder.rb
test/spec_rack_camping.rb
test/spec_rack_cascade.rb
test/spec_rack_cgi.rb
test/spec_rack_chunked.rb
test/spec_rack_commonlogger.rb
test/spec_rack_conditionalget.rb
test/spec_rack_content_length.rb
test/spec_rack_content_type.rb
test/spec_rack_deflater.rb
test/spec_rack_directory.rb
test/spec_rack_fastcgi.rb
test/spec_rack_file.rb
test/spec_rack_handler.rb
test/spec_rack_head.rb
test/spec_rack_lint.rb
test/spec_rack_lobster.rb
test/spec_rack_lock.rb
test/spec_rack_methodoverride.rb
test/spec_rack_mock.rb
test/spec_rack_mongrel.rb
test/spec_rack_recursive.rb
test/spec_rack_request.rb
test/spec_rack_response.rb
test/spec_rack_rewindable_input.rb
test/spec_rack_session_cookie.rb
test/spec_rack_session_memcache.rb
test/spec_rack_session_pool.rb
test/spec_rack_showexceptions.rb
test/spec_rack_showstatus.rb
test/spec_rack_static.rb
test/spec_rack_thin.rb
test/spec_rack_urlmap.rb
test/spec_rack_utils.rb
test/spec_rack_webrick.rb
test/testrequest.rb
test/unregistered_handler
test/unregistered_handler/rack
test/unregistered_handler/rack/handler
test/unregistered_handler/rack/handler/unregistered.rb
test/unregistered_handler/rack/handler/unregistered_long_one.rb
)
  
end
