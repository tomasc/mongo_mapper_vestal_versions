module MongoMapper::Plugins::VestalVersions
  # The MongoMapper model representing versions.
  class Version
    include Comparable
    include MongoMapper::EmbeddedDocument
    
    # version number
    key :number, Integer, :default => 1
    
    # store changes
    key :changes, Hash
    
    # tags
    key :tag, String

    # timestamps
    # these needs to be set manually, not through callback
    # to handle creating versions on update_attributes
    key :created_at, Time
    key :updated_at, Time

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
