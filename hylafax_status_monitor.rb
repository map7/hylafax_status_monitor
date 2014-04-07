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

# Get the output from the Faxstat
output = %x(faxstat)

text = get_output(output)
status = status(text)

if status
  puts "Fax is running successfully"
else
  puts "Fax is down\n"
  puts output

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
end
