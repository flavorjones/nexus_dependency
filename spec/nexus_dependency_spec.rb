require 'spec/spec_helper'

describe Nexus::Dependency do
  describe ".new" do
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

  describe "#install" do
    before do
      @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/", :version => "2.1"
      @nonmatching_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.0")
      @matching_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.1")
    end

    context "nothing is installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(nil)
      end

      it "should call update" do
        @dependency.should_receive(:update)
        @dependency.install
      end
    end

    context "a non-matching package is installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(@nonmatching_artifact)
      end

      it "should call update" do
        @dependency.should_receive(:update)
        @dependency.install
      end
    end

    context "a matching package is installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(@matching_artifact)
      end

      it "should not call update" do
        @dependency.should_not_receive(:update)
        @dependency.install
      end
    end
  end

  describe "#update" do
    before do
      @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/"
      @installed_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.0")
      @desired_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.1")
    end

    context "nothing is installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(nil)
        @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
      end

      it "should call #update!" do
        @dependency.should_receive(:update!)
        @dependency.update
      end
    end

    context "a package with a different version is installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(@installed_artifact)
        @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
      end

      it "should call #update!" do
        @dependency.should_receive(:update!)
        @dependency.update
      end
    end

    context "the artifact is already installed" do
      before do
        @dependency.stub!(:installed_artifact).and_return(@desired_artifact)
        @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
      end

      it "should not call #update!" do
        @dependency.should_not_receive(:update!)
        @dependency.update
      end
    end
  end

  describe "#update!" do
    before do
      @desired_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.1", 'packaging' => 'jar')
      @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/foo-bar-bazz-2.1.jar", :version => "2.1"
      @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
    end

    it "downloads the remote package that matches the desired artifact" do
      @dependency.repository.should_receive(:download).with(@desired_artifact).and_return("FOO BAR BAZZ")
      @dependency.update!
      File.should exist("vendor/nexus/foo-bar-bazz-2.1.jar")
      File.read("vendor/nexus/foo-bar-bazz-2.1.jar").should == "FOO BAR BAZZ"
    end

    it "writes the artifact of the newly-installed package" do
      @dependency.repository.stub!(:download).with(@desired_artifact)
      @dependency.update!
      File.should exist("vendor/nexus/foo.artifact")
      Nexus::Artifact.new(YAML.load_file("vendor/nexus/foo.artifact")).should == @desired_artifact
    end

    it "symlinks a generic name to the versioned package" do
      @dependency.repository.stub!(:download).with(@desired_artifact)
      @dependency.update!
      File.should exist("vendor/nexus/foo.jar")
      File.symlink?("vendor/nexus/foo.jar").should be_true
      File.readlink("vendor/nexus/foo.jar").should == "foo-bar-bazz-2.1.jar"
    end

    context "it's a tar.gz" do
      before do
        @desired_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.1", 'packaging' => 'tar.gz')
        @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/foo-bar-bazz-2.1.tar.gz", :version => "2.1"
        @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
        @test_archive = File.read File.join(TEST_ASSET_DIRECTORY, "foo.tar.gz")
      end

      it "unarchives the contents into a versioned directory" do
        @dependency.repository.should_receive(:download).with(@desired_artifact).and_return(@test_archive)
        @dependency.update!
        File.directory?("vendor/nexus/foo-bar-bazz-2.1").should be_true
        File.exists?("vendor/nexus/foo-bar-bazz-2.1/bin/foo").should be_true
        File.exists?("vendor/nexus/foo-bar-bazz-2.1/lib/foo.so").should be_true
      end

      it "symlinks a generic name to the versioned directory" do
        @dependency.repository.should_receive(:download).with(@desired_artifact).and_return(@test_archive)
        @dependency.update!
        File.symlink?("vendor/nexus/foo").should be_true
        File.readlink("vendor/nexus/foo").should == "foo-bar-bazz-2.1"
      end
    end

    context "the desired artifact is already installed" do
      before do
        FileUtils.rm_f "vendor/nexus/foo-bar-bazz-2.1.jar"
        FileUtils.touch "vendor/nexus/foo-bar-bazz-2.1.jar"
      end

      it "should blow away the package" do
        File.read("vendor/nexus/foo-bar-bazz-2.1.jar").should == ""
        @dependency.repository.should_receive(:download).with(@desired_artifact).and_return("FOO BAR BAZZ")
        @dependency.update!
        File.read("vendor/nexus/foo-bar-bazz-2.1.jar").should == "FOO BAR BAZZ"
      end

      context "it's a tar.gz" do
        before do
          @desired_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.1", 'packaging' => 'tar.gz')
          @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/foo-bar-bazz-2.1.tar.gz", :version => "2.1"
          @dependency.stub!(:desired_artifact).and_return(@desired_artifact)
          FileUtils.rm_rf "vendor/nexus/foo-bar-bazz-2.1"
          FileUtils.mkdir "vendor/nexus/foo-bar-bazz-2.1"
          FileUtils.touch "vendor/nexus/foo-bar-bazz-2.1/should-be-removed"
        end

        it "should blow away the directory" do
          test_archive = File.read File.join(TEST_ASSET_DIRECTORY, "foo.tar.gz")
          @dependency.repository.should_receive(:download).with(@desired_artifact).and_return(test_archive)
          @dependency.update!
          File.exists?("vendor/nexus/foo-bar-bazz-2.1/should-be-removed").should be_false
          File.exists?("vendor/nexus/foo-bar-bazz-2.1/bin/foo").should be_true
        end
      end
    end
  end

  describe "#installed_artifact" do
    before do
      @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/foo-bar-bazz-2.1.tar.gz", :version => "2.1"
      FileUtils.rm_rf "vendor/nexus"
      FileUtils.mkdir "vendor/nexus"
    end

    context "given an artifact is installed" do
      before do
        @installed_artifact = Nexus::Artifact.new('artifactId' => 'foo', 'version' => "2.0", 'packaging' => 'tar.gz')
        File.open "vendor/nexus/foo.artifact", "w" do |f|
          f.write @installed_artifact.to_hash.to_yaml
        end
      end

      it "returns the artifact of the installed package" do
        @dependency.installed_artifact.should == @installed_artifact
      end
    end

    context "given an artifact is not installed" do
      it "returns nil" do
        @dependency.installed_artifact.should be_nil
      end
    end
  end

  describe "#desired_artifact" do
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

  describe "#project_attributes" do
    before do
      @dependency = Nexus::Dependency.new :name => "foo", :uri => "http://sample.net/", :group => "bar", :version => "2.2"
    end

    it "should include what we're projecting by" do
      @dependency.project_attributes([:group])[:group].should == "bar"
    end

    it "should not include what we're not projecting by" do
      @dependency.project_attributes([:group]).should_not have_key(:version)
    end
  end
end
