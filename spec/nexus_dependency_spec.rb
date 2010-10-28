require 'spec/spec_helper'

describe Nexus::Dependency do
  describe "new" do
    it "should be callable" do
      d = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/"
      d.should be_instance_of(Nexus::Dependency)
    end

    context "required attributes" do
      it "should require a name and a URI" do
        proc {
          Nexus::Dependency.new
        }.should raise_error

        proc {
          Nexus::Dependency.new :name => "foo"
        }.should raise_error

        proc {
          Nexus::Dependency.new :uri => "http://sample.net/"
        }.should raise_error

        proc {
          Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/"
        }.should_not raise_error
      end
    end

    it "should store options" do
      attributes = {:name => "foo", :uri => "http://sample.net/", :a => 1, :b => 2}
      d = Nexus::Dependency.new attributes
      d.attributes.should == attributes
    end
  end

  describe ".install" do
  end

  describe ".update" do
  end

  describe ".desired_artifact" do
    context "without artifact options" do
      before { @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/" }

      it "should retrieve matching artifacts" do
        repository = Nexus::Repository.new "http://sample.net/"
        repository.should_receive(:find_artifacts).and_return([Nexus::Artifact.new({})])
        Nexus::Repository.should_receive(:new).with("http://sample.net/").and_return(repository)

        @dependency.desired_artifact
      end

      context "multiple versions of the named artifact" do
        before do
          artifacts = [
            Nexus::Artifact.new('version' => "2.0", 'artifactId' => "foo"),
            Nexus::Artifact.new('version' => "3.0", 'artifactId' => "foo"),
            Nexus::Artifact.new('version' => "1.0", 'artifactId' => "foo"),
          ]
          repository = Nexus::Repository.new "http://sample.net/"
          repository.stub!(:find_artifacts).and_return(artifacts)
          Nexus::Repository.stub!(:new).and_return(repository)
        end

        it "should return the artifact with the most recent version" do
          @dependency.desired_artifact.version.should == "3.0"
        end
      end
    end

    context "with artifact options provided for filtering multiple artifacts" do
      before do
        @artifacts = [
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.0", 'groupId' => "foo", 'packaging' => "jar"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.0", 'groupId' => "foo", 'packaging' => "tar.gz"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.0", 'groupId' => "bar", 'packaging' => "jar"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.0", 'groupId' => "bar", 'packaging' => "tar.gz"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.2", 'groupId' => "foo", 'packaging' => "jar"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.2", 'groupId' => "foo", 'packaging' => "tar.gz"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.2", 'groupId' => "bar", 'packaging' => "jar"),
          Nexus::Artifact.new('artifactId' => 'shizzle', 'version' => "2.2", 'groupId' => "bar", 'packaging' => "tar.gz"),
        ]
        repository = Nexus::Repository.new "http://sample.net/"
        repository.stub!(:find_artifacts).and_return(@artifacts)
        Nexus::Repository.stub!(:new).and_return(repository)
      end

      it "should return only matching artifacts" do
        @artifacts.each do |desired_artifact|
          dependency = Nexus::Dependency.new :uri => "http://sample.net/",
                                             :name => desired_artifact.name,
                                             :version => desired_artifact.version,
                                             :group => desired_artifact.group,
                                             :type => desired_artifact.type
          dependency.desired_artifact.should == desired_artifact
        end
      end

      it "should return nil if a matching artifact was not found" do
        dependency = Nexus::Dependency.new :uri => "http://sample.net/", :name => "foobar"
        dependency.desired_artifact.should be_nil
      end

      context "multiple matches" do
        it "should return the artifact with the most recent version" do
          dependency = Nexus::Dependency.new :uri => "http://sample.net/", :name => "shizzle", :type => "jar", :group => "foo"
          dependency.desired_artifact.version.should == "2.2"
        end
      end
    end
  end

  describe ".artifact_query_attributes" do
    before { @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/", :type => 'tar.gz', :group => "bar" }

    it "should include :group" do
      @dependency.artifact_query_attributes[:group].should == "bar"
    end

    it "should include :name" do
      @dependency.artifact_query_attributes[:name].should == "foo"
    end

    it "should include :type" do
      @dependency.artifact_query_attributes[:type].should == "tar.gz"
    end

    it "should ignore everything else" do
      @dependency.artifact_query_attributes.should_not have_key(:uri)
    end
  end

  describe ".artifact_attributes" do
    before { @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/", :type => 'tar.gz', :group => "bar", :version => "2.2", :repo => "shizzle", :classifier => "large" }

    it "should include :group" do
      @dependency.artifact_attributes[:group].should == "bar"
    end

    it "should include :name" do
      @dependency.artifact_attributes[:name].should == "foo"
    end

    it "should include :type" do
      @dependency.artifact_attributes[:type].should == "tar.gz"
    end

    it "should include :version" do
      @dependency.artifact_attributes[:version].should == "2.2"
    end

    it "should include :repo" do
      @dependency.artifact_attributes[:repo].should == "shizzle"
    end

    it "should include :classifier" do
      @dependency.artifact_attributes[:classifier].should == "large"
    end

    it "should ignore everything else" do
      @dependency.artifact_attributes.should_not have_key(:uri)
    end
  end
end
