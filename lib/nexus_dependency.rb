require "rake"
require "rnexus"

module Nexus
  class Dependency
    VERSION = '1.0.0'
    ARTIFACT_ATTRIBUTES = [:group, :name, :type, :version, :repo, :classifier]
    QUERY_ATTRIBUTES = [:group, :name, :type]

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
      possible_matches = repository.find_artifacts project_attributes(QUERY_ATTRIBUTES)
      possible_matches = possible_matches.select do |possible_match|
        artifact_matches? possible_match
      end
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

    def project_attributes attribute_names
      attributes.inject({}) do |hash, kv|
        hash[kv.first] = kv.last if attribute_names.include?(kv.first)
        hash
      end
    end

    private

    def artifact_matches? artifact
      project_attributes(ARTIFACT_ATTRIBUTES).inject(true) do |state, keyval|
        state && artifact.send(keyval.first) == keyval.last
      end
    end
  end
end

require "nexus_dependency/rake"
