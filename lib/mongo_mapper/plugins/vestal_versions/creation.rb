module MongoMapper::Plugins::VestalVersions
  # Adds the functionality necessary to control version creation on a versioned instance of
  # MongoMapper::Document.
  module Creation
    def self.included(base) # :nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods

        after_update :create_version, :if => :create_version?
        after_update :update_version, :if => :update_version?

        class << self
          alias_method_chain :prepare_versioned_options, :creation
        end
      end
    end

    # Class methods added to ActiveRecord::Base to facilitate the creation of new versions.
    module ClassMethods
      # Overrides the basal +prepare_versioned_options+ method defined in VestalVersions::Options
      # to extract the <tt>:only</tt> and <tt>:except</tt> options into +vestal_versions_options+.
      def prepare_versioned_options_with_creation(options)
        result = prepare_versioned_options_without_creation(options)

        self.vestal_versions_options[:only] = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
        self.vestal_versions_options[:except] = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]

        result
      end
    end

    # Instance methods that determine whether to save a version and actually perform the save.
    module InstanceMethods
      private
        # Returns whether a new version should be created upon updating the parent record.
        def create_version?
          !version_changes.blank?
        end

        # Creates a new version upon updating the parent record.
        def create_version
          versions.build(version_attributes)
          reset_version_changes
          reset_version
        end

        # Returns whether the last version should be updated upon updating the parent record.
        # This method is overridden in VestalVersions::Control to account for a control block that
        # merges changes onto the previous version.
        def update_version?
          false
        end

        # Updates the last version's changes by appending the current version changes.
        def update_version
          return create_version unless v = versions.last
          
          # v.changes_will_change!
          # v.update_attribute(:changes, v.changes.append_changes(version_changes))
          
          # automic update
          v.changes = v.changes.append_changes(version_changes)
          v.updated_at = Time.now.utc
          self.class.set({:_id => id, "versions.number" => v.number}, "versions.$.changes" => v.changes)
          
          reset_version_changes
          reset_version
        end

        # Returns an array of column names that should be included in the changes of created
        # versions. If <tt>vestal_versions_options[:only]</tt> is specified, only those columns
        # will be versioned. Otherwise, if <tt>vestal_versions_options[:except]</tt> is specified,
        # all columns will be versioned other than those specified. Without either option, the
        # default is to version all columns. At any rate, the four "automagic" timestamp columns
        # maintained by Rails are never versioned.
        def versioned_columns
          case
            when vestal_versions_options[:only] then self.attributes.keys & vestal_versions_options[:only]
            when vestal_versions_options[:except] then self.attributes.keys - vestal_versions_options[:except]
            else self.attributes.keys
          end - %w(created_at created_on updated_at updated_on versions _id _type)
        end

        # Specifies the attributes used during version creation. This is separated into its own
        # method so that it can be overridden by the VestalVersions::Users feature.
        def version_attributes
          now = Time.now.utc
          { :number => last_version + 1, :changes => version_changes, :created_at => now, :updated_at => now }
        end
    end
  end
end
