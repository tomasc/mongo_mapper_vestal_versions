module MongoMapper::Plugins::VestalVersions
  # The MongoMapper model representing versions.
  class Version
    include Comparable
    
    # version is standard document (not embedded)
    # this way we do not need to be afraid of the 4MB MongoDB limit
    include MongoMapper::Document
    include MongoMapper::Plugins::Timestamps
    
    # version number
    key :number, Integer, :default => 1
    
    # store changes
    key :model_changes, Hash
    
    # tags
    key :tag, String
    
    # Associate polymorphically with the parent record.
    key :versioned_id, ObjectId
    key :versioned_type, String
    belongs_to :versioned, :polymorphic => true
    
    # timestamps
    timestamps!

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
