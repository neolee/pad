require 'rubygems' if RUBY_VERSION < "1.9"
require 'data_mapper'

# DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://pad:nirvana@localhost/pad')

# Entities
class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :twitter, String, :length => 120
  property :email, String, :length => 120, :format => :email_address
  property :password, String, :length => 200
  property :avatar, String, :length => 255
  property :enabled, Boolean, :default  => true
  property :created_at, DateTime
end

class Dungeon
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 140, :required => true
  property :boss, String, :length => 5, :required => true
  property :technical, Boolean
  property :advent, Boolean
  property :limited, Boolean
  property :created_at, DateTime
end

class Leader
  include DataMapper::Resource
  property :id, Serial
  property :leader, String, :length => 5, :required => true
  property :friend, String, :length => 5, :required => true
  property :created_at, DateTime
end

class Solution
  include DataMapper::Resource
  property :id, Serial
  property :team, String, :length => 30, :required => true
  property :memo, Text
  property :created_at, DateTime
end

# Relationships
class Solution
  has 1, :leader
  has n, :dungeon
end

DataMapper.finalize

User.auto_upgrade!
Dungeon.auto_upgrade!
Leader.auto_upgrade!
Solution.auto_upgrade!
