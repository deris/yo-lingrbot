require './model.rb'

class Database
  SEED_FILE = './db/seed.rb'

  def connect
    DataMapper.finalize
    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:db/test.db')
    self
  end

  def migrate
    DataMapper.auto_upgrade!
    self
  end

  def migrate!
    DataMapper.auto_migrate!
    self
  end

  def seed
    load(SEED_FILE) if File.exist?(SEED_FILE)
  end
end
