module Cassie::Schema
  class Version
    include Comparable
    PARTS = [:major, :minor, :patch, :build].freeze

    attr_accessor :id,
                  :parts,
                  :description,
                  :migrator,
                  :migrated_at


    def initialize(version_number, description=nil, id=nil, migrator=nil, migrated_at=nil)
      @parts = build_parts(version_number)
      @description    = description
      @id             = id
      @migrator       = migrator
      @migrated_at    = migrated_at
    end

    def number
      parts.join('.')
    end

    def major
      parts[0].to_i
    end

    def minor
      parts[1].to_i
    end

    def patch
      parts[2].to_i
    end

    def build
      parts[3].to_i
    end

    def next_version(bump=nil)
      bump ||= :patch
      bump_index = PARTS.index(bump.to_sym)

      # 0.2.1 - > 0.2
      bumped_parts = parts.take(bump_index + 1)
      # 0.2 - > 0.3
      bumped_parts[bump_index] = bumped_parts[bump_index].to_i + 1
      # 0.3 - > 0.3.0.0
      bumped_parts += [0]*(PARTS.length - (bump_index + 1))
      self.class.new(bumped_parts.join('.'))
    end

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

    def to_h
      {
        id: id,
        number: number,
        description: description,
        migrator: migrator,
        migrated_at: migrated_at
      }
    end

    def to_s
      number
    end

    protected

    def build_parts(version_number)
      included = version_number.split('.').map{|p| p.to_i}
      included + [0]*(PARTS.length - included.length)
    end
  end
end