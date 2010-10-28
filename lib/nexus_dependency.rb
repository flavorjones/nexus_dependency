require "rake"
require "rnexus"

module Nexus
  class Dependency
    VERSION = '1.0.0'

    attr_reader :attributes

    def initialize(attributes={})
      raise ArgumentError, "must specify :name" unless attributes[:name]
      raise ArgumentError, "must specify :uri"  unless attributes[:uri]
      @attributes = attributes
    end

    def install
      raise NotImplementedError
      update unless installed_artifact_satisfies? to_hash
    end

    def update
      raise NotImplementedError
      unless installed_artifact_satisfies? desired_artifact
        download_artifact
        # unpack_artifact
        # symlink_artifact
      end
    end

    def to_hash
      raise NotImplementedError
      options.merge(:name => attributes[:name])
    end

    def installed_artifact_satisfies? other
      raise NotImplementedError
      if installed_artifact
        if Nexus::Artifact === other
          # TODO
        elsif Hash === other
          # TODO
        end
      end
      false
    end

    def installed_artifact
      raise NotImplementedError
      @installed_artifact ||= begin
                                # TODO
                              end
    end

    def desired_artifact
      possible_matches = repository.find_artifacts artifact_attributes
      possible_matches.inject(possible_matches.first) do |best, current|
        if best.version && current.version && current.version > best.version
          current
        else
          best
        end
      end
    end

    def repository
      @repository ||= Nexus::Repository.new attributes[:uri]
    end

    def artifact_attributes
      attributes.inject({}) do |hash, kv|
        hash[kv.first] = kv.last if [:group, :name, :type].include?(kv.first)
        hash
      end
    end
  end
end

require "nexus_dependency/rake"
