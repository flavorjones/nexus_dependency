require "rake"
require "nexus_dependency"

#
#  Rake tasks 'nexus:install' and 'nexus:update' are created if any nexus dependencies are declared.
#
#  'nexus:install' will check that requirements are currently met, and
#  download any additional packages that are necessary into 'vendor/nexus'.
#
module Nexus
  module Rake
    
    def self.append_features(base)
      base.extend ClassMethods
    end

    module ClassMethods
      #  Declare a nexus dependency. This creates rake tasks for 'nexus:install' and 'nexus:update'.
      #
      #  +options+ is a hash whose keys MUST include:
      #  * :name - package name (nexus 'artifactId')
      #  * :uri - repository URI (nexus 'resourceURI')
      #  and whose keys CAN include the following artifact specifications:
      #  * :version - nexus 'version' (e.g., "2.1.0")
      #  * :group - nexus 'groupId'
      #  * :type - nexus 'packaging' (e.g., 'tar.gz', 'jar', etc.)
      #  * :repo - nexus 'repoId'
      #  * :classifier - nexus 'classifier'
      #
      #  If an artifact specification option is specified, then packages will be filtered by that parameter.
      #  If no artifact specification options are specified, then no filtering will be done.
      #
      #  If +:version+ is not specified, then 'nexus:update' will install the most recent version.
      #
      #  Example:
      #    nexus :name => 'activemq', :uri => 'http://nexus.local/nexus'
      #    nexus :name => 'activemq', :uri => 'http://nexus.local/nexus', :packaging => 'tar.gz'
      #    nexus :name => 'activemq', :uri => 'http://nexus.local/nexus', :version => "5.4.0", :packaging => 'tar.gz'
      #
      def nexus(attributes={})
        ::Rake.application.in_namespace "nexus" do
          ::Rake::Task.define_task :install do
            ::Nexus::Dependency.new(attributes).install
          end
          ::Rake::Task.define_task :update do
            ::Nexus::Dependency.new(attributes).update
          end
        end
      end
    end
  end
end
