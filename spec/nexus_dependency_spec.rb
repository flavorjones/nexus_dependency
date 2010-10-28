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
            Nexus::Artifact.new('version' => "2.0"),
            Nexus::Artifact.new('version' => "3.0"),
            Nexus::Artifact.new('version' => "1.0"),
          ]
          repository = Nexus::Repository.new "http://sample.net/"
          repository.stub!(:find_artifacts).and_return(artifacts)
          Nexus::Repository.stub!(:new).and_return(repository)
        end

        it "should select the most recent version" do
          @dependency.desired_artifact.version.should == "3.0"
        end
      end
    end

    context "with artifact options" do
    end
  end

  describe ".artifact_attributes" do
    before { @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/", :type => 'tar.gz', :group => "bar" }

    it "should include :group" do
      @dependency.artifact_attributes[:group].should == "bar"
    end

    it "should include :name" do
      @dependency.artifact_attributes[:name].should == "foo"
    end

    it "should include :type" do
      @dependency.artifact_attributes[:type].should == "tar.gz"
    end

    it "should ignore everything else" do
      @dependency.artifact_attributes.should_not have_key(:uri)
    end
  end
end
