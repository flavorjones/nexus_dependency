require 'spec/spec_helper'

describe Nexus::Rake do
  class FakeRake
    include Rake
    include Nexus::Rake
  end

  def fake_rake(&block)
    FakeRake.class_eval &block
  end

  def new_tasks(name=nil, &block)
    tasks_before = Rake::Task.tasks
    yield
    tasks = Rake::Task.tasks - tasks_before
    if name
      tasks.select { |t| t.name == name }
    else
      tasks
    end
  end

  before do
    Rake::Task.clear
  end

  describe "DSL" do
    describe "nexus" do
      it "creates two rake tasks for installing and updating nexus packages" do
        tasks = new_tasks do
          fake_rake do
            nexus({}) 
          end
        end
        tasks.length.should == 2
        tasks[0].should be_instance_of(Rake::Task)
        tasks[1].should be_instance_of(Rake::Task)
      end

      it "creates a 'nexus:install' rake task that invokes Nexus::Dependency#install" do
        tasks = new_tasks "nexus:install" do
          fake_rake { nexus({}) }
        end
        tasks.length.should == 1

        mock_dependency = Nexus::Dependency.new "foo"
        mock_dependency.should_receive(:install).and_return(nil)
        Nexus::Dependency.should_receive(:new).and_return(mock_dependency)

        tasks.first.execute
      end

      it "creates a 'nexus:update' rake task that invokes Nexus::Dependency#update" do
        tasks = new_tasks "nexus:update" do
          fake_rake { nexus({}) }
        end
        tasks.length.should == 1

        mock_dependency = Nexus::Dependency.new "foo"
        mock_dependency.should_receive(:update).and_return(nil)
        Nexus::Dependency.should_receive(:new).and_return(mock_dependency)

        tasks.first.execute
      end
    end
  end
end
