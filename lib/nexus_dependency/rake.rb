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
      #  +name+ is the nexus 'artifactId'.
      #
      #  +options+ is a hash whose keys can include
      #  * :group_id - nexus 'groupId'
      #  * :version - nexus 'version' (e.g., "release-2.1.0")
      #  * :packaging - nexus 'packaging' (e.g., 'tar.gz', 'jar', etc.)
      #  * :repo_id - nexus 'repoId'
      #  * :classifier - nexus 'classifier'
      #
      #  If an option is specified, then packages will be filtered by that parameter.
      #  If an option is not specified, then no filtering will be done.
      #  If +:version+ is not specified, then you'll receive the most recent version (naively, the last package when sorted by 'version')
      #
      #  Example:
      #    nexus 'activemq'
      #    nexus 'activemq', :version => "5.4.0", :packaging => 'tar.gz'
      #
      def nexus(name, options={})
        ::Rake.application.in_namespace "nexus" do
          ::Rake::Task.define_task :install do
            ::Nexus::Dependency.new(name, options).install
          end
          ::Rake::Task.define_task :update do
            ::Nexus::Dependency.new(name, options).update
          end
        end
      end
    end
  end
end

