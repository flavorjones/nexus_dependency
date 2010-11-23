require "rake"
require "rnexus"

module Nexus
  class Dependency
    VERSION = '1.0.0'
    ARTIFACT_ATTRIBUTES = [:group, :name, :type, :version, :repo, :classifier]
    QUERY_ATTRIBUTES = [:group, :name, :type]
    RELATIVE_CACHE_PATH = "vendor/nexus"

    attr_reader :attributes

    def initialize(attributes={})
      raise ArgumentError, "must specify :name" unless attributes[:name]
      raise ArgumentError, "must specify :uri"  unless attributes[:uri]
      @attributes = attributes
    end

    def install
      update unless artifact_matches? installed_artifact
    end

    def update
      update! unless installed_artifact == desired_artifact
    end

    def update!
      FileUtils.mkdir_p RELATIVE_CACHE_PATH
      File.open("#{RELATIVE_CACHE_PATH}/#{attributes[:name]}.artifact","w") { |f| f.write desired_artifact.to_hash.to_yaml }
    end

    def installed_artifact
      raise NotImplementedError
      @installed_artifact ||= begin
                                # TODO
                              end
    end

    def desired_artifact
      possible_matches = repository.find_artifacts project_attributes(QUERY_ATTRIBUTES)
      possible_matches = possible_matches.select { |a| artifact_matches? a }
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
      return false if artifact.nil?
      project_attributes(ARTIFACT_ATTRIBUTES).inject(true) do |state, keyval|
        state && artifact.send(keyval.first) == keyval.last
      end
    end
  end
end

require "nexus_dependency/rake"
