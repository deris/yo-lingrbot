require 'bundler'
Bundler.setup
require './database.rb'

task :default => 'db:setup'

desc 'Migrate database'
task 'db:migrate' do
  puts 'Upgrading Database...'
  Database.new.connect.migrate
end

desc 'Execute seed script'
task 'db:seed' do
  puts 'Initializing Database...'
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper.logger.set_log STDERR, :debug, "SQL: ", true
  Database.new.connect.seed
end

desc 'Delete database'
task 'db:delete' do
  puts 'Delete Database...'
  Database.new.connect.migrate!
end

desc 'Add Lingr Room Info'
task 'yo:add', 'name', 'yo_username', 'yo_api_token'
task 'yo:add' do |task, args|
  puts 'Adding Lingr Room Info...'
  LingrRoom.create!(
    :name         => args.name,
    :yo_username  => args.yo_username,
    :yo_api_token => args.yo_api_token,
  )
end

desc 'Reset database'
task 'db:reset' => %w(db:delete db:seed)

desc 'Set up database'
task 'db:setup' => %w(db:migrate db:seed)

