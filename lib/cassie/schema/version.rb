module Cassie::Schema
  class Version
    include Comparable
    PARTS = [:major, :minor, :patch, :build].freeze

    # The version uuid, if persisted
    # @return [Cassandra::TimeUuid]
    attr_accessor :id
    # The major, minor, patch, and build parts making up the semantic version
    # @return [Array<Fixnum>]
    attr_accessor :parts
    # The description of the changes introduced in this version
    # @return [String]
    attr_accessor :description
    # The OS username of the user that migrated this version up
    # @return [String]
    attr_accessor :executor
    # The time this version was migrated up
    # @return [DateTime]
    attr_accessor :executed_at


    def initialize(version_number, description=nil, id=nil, executor=nil, executed_at=nil)
      @parts = build_parts(version_number)
      @description    = description
      @id             = id
      @executor       = executor
      @executed_at    = executed_at
    end

    def number
      parts.join('.')
    end

    # The major part of the semantic version
    # @!parse attr_reader :major
    def major
      parts[0].to_i
    end

    # The minor part of the semantic version
    # @!parse attr_reader :minor
    def minor
      parts[1].to_i
    end

    # The patch part of the semantic version
    # @!parse attr_reader :patch
    def patch
      parts[2].to_i
    end

    # The build part of the semantic version
    # @!parse attr_reader :build
    def build
      parts[3].to_i
    end

    # Builds a new version, wiht a version number incremented from this
    # object's version. Does not propogate any other attributes
    # @option bump_type [Symbol] :build Bump the build version
    # @option bump_type [Symbol] :patch Bump the patch version, set build to 0
    # @option bump_type [Symbol] :minor Bump the minor version, set patch and build to 0
    # @option bump_type [Symbol] :major Bump the major version, set minor, patch, and build to 0
    # @option bump_type [nil] nil Default, bumps patch, sets build to 0
    # @return [Version]
    def next(bump_type=nil)
      bump_type ||= :patch
      bump_index = PARTS.index(bump_type.to_sym)

      # 0.2.1 - > 0.2
      bumped_parts = parts.take(bump_index + 1)
      # 0.2 - > 0.3
      bumped_parts[bump_index] = bumped_parts[bump_index].to_i + 1
      # 0.3 - > 0.3.0.0
      bumped_parts += [0]*(PARTS.length - (bump_index + 1))
      self.class.new(bumped_parts.join('.'))
    end

    # Compares versions by semantic version number
    def <=>(other)
      case other
      when Version
        Gem::Version.new(self.number) <=> Gem::Version.new(other.number)
      when String
        Gem::Version.new(self.number) <=> Gem::Version.new(other)
      else
        nil
      end
    end

    # The migration class name, as implied by the version number
    # @example 1.2.3
    #   migration_class_name
    #   #=> "Migration_1_2_3_0"
    def migration_class_name
      "Migration_#{major}_#{minor}_#{patch}_#{build}"
    end

    # The migration associated with this version
    # @return nil if the expected migration class is not defined
    # @!parse attr_reader :migration
    def migration
      @migration ||= begin
        migration_class_name.constantize.new
      rescue NameError
        nil
      end
    end

    def to_h
      {
        id: id,
        number: number,
        description: description,
        executor: executor,
        executed_at: executed_at
      }
major, minor, patch, and build parts of the version    end

    def to_s
      number
    end

    protected

    def build_parts(version_number)
      included = version_number.to_s.split('.').map{|p| p.to_i}
      included + [0]*(PARTS.length - included.length)
    end
  end
end