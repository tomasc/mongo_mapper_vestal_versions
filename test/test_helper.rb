require 'rubygems'
require 'bundler/setup'
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'mongo_mapper'
require 'init'
require 'ruby-debug'
require 'shoulda'



class ActiveSupport::TestCase
	
	# Drop all collections after each test case.
  def teardown
    MongoMapper.database.collections.each { |coll| coll.remove }
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do 
      super
    end
  end

end



MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "vestal_versions_test"
MongoMapper.database.collections.each { |c| c.drop_indexes }



# CLASS SETUP

class User
	include MongoMapper::Document
	plugin MongoMapper::Plugins::VestalVersions

	key :first_name, String
	key :last_name, String
	
	many :embedded_items
	
	versioned
	
	def name
    [first_name, last_name].compact.join(' ')
	end
	
	def name=(names)
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
  
end

class MyCustomVersion < MongoMapper::Plugins::VestalVersions::Version
end

class EmbeddedItem
  include MongoMapper::EmbeddedDocument
  key :title, String
end