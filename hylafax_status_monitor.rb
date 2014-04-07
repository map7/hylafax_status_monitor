#!/usr/bin/env ruby

require_relative 'lib/status.rb'
require 'json'
require 'mail'

# Read in settings
begin
  serialized = File.read("/etc/hylafax_status_monitor.json")
  data = JSON.parse(serialized)
  email = data["email"]
rescue
  puts "Please create a /etc/hylafax_status_monitor.json file"
  exit
end

def get_status
  # Get the output from the Faxstat
  output = %x(faxstat)
  text = get_output(output)
  status = status(text)
end

if get_status == false
  puts "Fax is down, attempting a restart"
  %x(service hylafax restart)
end

if get_status
  puts "Fax is running successfully"
  set_status(false) # Record that we haven't sent any error messages
else
  puts "Fax is down still down\n"
  puts output

  if sent_status(status) == false
    # Set up delivery defaults to use inhouse mail server
    Mail.defaults do
      delivery_method :smtp, {
        :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE, 
        :address => 'mail.lan',
        :port => '587',
        :enable_starttls_auto => true
      }
    end
    
    # If we have a problem email the output to my email address
    Mail.deliver do
      from email
      to email
      subject "Fax is down"
      body output
    end
    
    puts "\nSending email to #{email}"
    set_status(true) # Record that we have sent the error email
  end
end
