module MongoMapper::Plugins::VestalVersions
  # The MongoMapper model representing versions.
  class Version
    include Comparable
    include MongoMapper::EmbeddedDocument
    
    plugin MongoMapper::Plugins::Timestamps

    # version number
    key :number, Integer, :default => 1
    
    # store changes
    key :changes, Hash
    
    # tags
    key :tag, String
    
    # time info
    timestamps!



    # ActiveRecord::Base#changes is an existing method, so before serializing the +changes+ column,
    # the existing +changes+ method is undefined. The overridden +changes+ method pertained to 
    # dirty attributes, but will not affect the partial updates functionality as that's based on
    # an underlying +changed_attributes+ method, not +changes+ itself.
    # undef_method :changes
    # serialize :changes, Hash




    # In conjunction with the included Comparable module, allows comparison of version records
    # based on their corresponding version numbers and creation timestamps.
    def <=>(other)
      [number, created_at].map(&:to_i) <=> [other.number, other.created_at].map(&:to_i)
    end

    # Returns whether the version has a version number of 1. Useful when deciding whether to ignore
    # the version during reversion, as initial versions have no serialized changes attached. Helps
    # maintain backwards compatibility.
    def initial?
      number == 1
    end
    
  end
end
