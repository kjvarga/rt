class Notifier < ActionMailer::Base
  self.template_root = "#{File.dirname(__FILE__)}/../views/"
  
  def site_error(url, response)
     content_type "text/html"
     recipients ExceptionNotifier.exception_recipients
     from       ExceptionNotifier.sender_address
     subject    ExceptionNotifier.email_prefix + ' ' + response.body[0..300]
     body       :response => response, :url => url
   end
end
