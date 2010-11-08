require File.join(File.dirname(__FILE__), 'test_helper')

# FIXME include the plugin to every MongoMapper::Document

class VersionedTest < Test::Unit::TestCase
  context 'MongoMapper models' do
    should 'respond to the "versioned?" method' do
      # assert MongoMapper::Document.respond_to?(:versioned?)
      assert User.respond_to?(:versioned?)
    end

    should 'return true for the "versioned?" method if the model is versioned' do
      assert_equal true, User.versioned?
    end

    should 'return false for the "versioned?" method if the model is not versioned' do
      # assert_equal false, MongoMapper::Document.versioned?
    end
  end
end
