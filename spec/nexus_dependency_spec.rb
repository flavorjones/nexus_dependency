require 'spec/spec_helper'

describe Nexus::Dependency do
  describe "new" do
    it "should require a name"

    context "options" do
      it "should store options"
    end
  end

  describe ".check_cache" do
    
  end

  describe ".resolve_dependency" do

  end

  describe ".get_artifact" do

  end

  describe ".unpack_artifact" do

  end

  describe ".symlink" do

  end

  describe ".install" do
    it "should call check_cache"

    context "check_cache returns false" do
      it "should get the artifact for the resolved dependency"
      it "should unpack the artifact into vendor/nexus"
      it "should symlink the artifact directory"
    end

    context "check_cache returns true" do
      it "should do nothing"
    end
  end

  describe ".update" do
    it "should call resolve_dependency"

    context "resolved dependency is newer than installed" do
      it "should get the artifact"
      it "should unpack the artifact into vendor/nexus"
      it "should symlink the artifact directory"
    end

    context "resolved dependency is older than or same as installed" do
      it "should do nothing"
    end
  end
end
