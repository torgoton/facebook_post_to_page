require "./.env" if File.exist?("./.env.rb")
require "./app"

run App

