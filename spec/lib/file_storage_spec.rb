require 'spec_helper'
require 'file_storage'
require 'tmpdir'
require 'fileutils.rb'
require 'rspec/rails/mocks.rb'

describe FileStorage do
  before(:each) do
    @temp = Dir.mktmpdir("FileStorage")
    @storage = FileStorage.new(@temp)
    @session = mock_model(MeegoTestSession, {
        :table_name => "foobar"
    })
  end

  after(:each) do
    FileUtils.remove_dir(@temp)
  end

  it "should return empty array when files are not stored for target" do
    @storage.list_files(@session).should == []
  end
  
  it "should be able to add file attachements of meego_test_session into storage and list them in alphabetical order" do
    @storage.add_file(@session, File.new('public/images/ajax-loader.gif'), 'foo.gif')
    @storage.list_files(@session).should == [{:name => "foo.gif", :path => "foobar/1002/foo.gif"}]
  end
end
