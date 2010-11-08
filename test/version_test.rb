require File.join(File.dirname(__FILE__), 'test_helper')

class VersionTest < Test::Unit::TestCase
  context 'Versions' do
    setup do
      @user = User.create(:name => 'Stephen Richert')
      @user.update_attributes(:name => 'Steve Jobs')
      @user.update_attributes(:last_name => 'Richert')
      @first_version, @last_version = @user.versions.first, @user.versions.last
    end

    should 'be comparable to another version based on version number' do
      assert @first_version == @first_version
      assert @last_version == @last_version
      assert @first_version != @last_version
      assert @last_version != @first_version
      assert @first_version < @last_version
      assert @last_version > @first_version
      assert @first_version <= @last_version
      assert @last_version >= @first_version
    end

    should "not equal a separate model's version with the same number" do
      user = User.create(:name => 'Stephen Richert')
      user.update_attributes(:name => 'Steve Jobs')
      user.update_attributes(:last_name => 'Richert')
      first_version, last_version = user.versions.first, user.versions.last
      assert_not_equal @first_version, first_version
      assert_not_equal @last_version, last_version
    end
    
    should 'default to ordering by number when finding through association' do
      order = @user.associations[:versions].query_options[:order]
      assert_equal :number, order.field
      assert_equal 'asc', order.operator
    end
    
    should 'return true for the "initial?" method when the version number is 1' do
      version = @user.versions.build(:number => 1)
      assert_equal 1, version.number
      assert_equal true, version.initial?
    end
  end
end
