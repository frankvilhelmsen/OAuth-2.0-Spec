require 'json'
require "base64"
require 'rubygems'
require 'test/unit'
require 'rack/test'

data = {}

Given /^I am logged in as "([^\"]*)" with "([^\"]*)"$/ do |username, password|
  authorize username, password
end

Then /^the status code is (\d+)$/ do |status_code|
     last_response.status.should eql status_code.to_i 
end

Then /^the content should contain "([^"]*)"$/ do | element |
  last_response.body.should include "#{element}"
end

Given /^the uri is "([^"]*)"$/ do |arg1|
  get(arg1)
end

When /^the uri is "([^"]*)" posting$/ do |arg1|
  # puts "#{JSON.generate(data)}"
  post arg1, JSON.generate(data), "CONTENT_TYPE" => "application/json"
end

When /^the respons is (\d+)$/ do |status|
    last_response.status.should eql status.to_i
end

When /^the content should be "([^"]*)"$/ do | content |
    last_response.body.should include content
end

Then /^the output should be unauthorized$/  do 
  last_response.status.should eql 401
  last_response.header.should_not include "Location"
end

Given /^the following user record$/ do |table|  
  table.hashes.each do |hash|  
    data[hash['key']] = hash['value']
  end  
end  

