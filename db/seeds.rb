#encoding: utf-8
require_relative '../lib/home/engine'

User.find_or_create_by name: "demo" do |a|
  a.email = "demo@example.com"
  a.password = "demo12345"
  a.isadmin = true
end
