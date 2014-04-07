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
  
  # If we have a problem email the output to my email address
  mail = Mail.new do
    from email
    to email
    subject "Fax is down"
    body output
  end
  mail.delivery_method :sendmail
  mail.deliver
  
  puts "\nSending email to #{email}"
end
