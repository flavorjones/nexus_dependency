require "rake"

module Nexus
  class Dependency
    VERSION = '1.0.0'

    def initialize(name, options={})
    end

    def install
    end
  end
end

require "nexus_dependency/rake"
