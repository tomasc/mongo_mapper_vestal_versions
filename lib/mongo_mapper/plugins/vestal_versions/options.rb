module MongoMapper::Plugins::VestalVersions
  # Provides +versioned+ options conversion and cleanup.
  module Options
    def self.included(base) # :nodoc:
      base.class_eval do
        extend ClassMethods
      end
    end

    # Class methods that provide preparation of options passed to the +versioned+ method.
    module ClassMethods
      # The +prepare_versioned_options+ method has three purposes:
      # 1. Populate the provided options with default values where needed
      # 2. Prepare options for use with the +has_many+ association
      # 3. Save user-configurable options in a class-level variable
      #
      # Options are given priority in the following order:
      # 1. Those passed directly to the +versioned+ method
      # 2. Those specified in an initializer +configure+ block
      # 3. Default values specified in +prepare_versioned_options+
      #
      # The method is overridden in feature modules that require specific options outside the
      # standard +has_many+ associations.
      def prepare_versioned_options(options)
        options.symbolize_keys!
        options.reverse_merge!(Configuration.options)
        options.reverse_merge!(
          :class => MongoMapper::Plugins::VestalVersions::Version,
          :dependent => :delete_all
        )
        options.reverse_merge!(
          :order => :number.asc
        )

        class_inheritable_accessor :vestal_versions_options
        self.vestal_versions_options = options.dup

        options.merge!(
          :as => :versioned,
          :extend => Array(options[:extend]).unshift(Versions)
        )
      end
    end
  end
end
