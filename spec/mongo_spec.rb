#run as 'spec spec'
require 'rubygems'
require 'mongo'
require 'mocha'

$: << File.dirname(__FILE__) + '/../lib'
require 'heroku'
require 'heroku/command'
require 'heroku/command/mongo'

include Mocha::API
describe Heroku::Command::Mongo do

  before do
    @mongo = Heroku::Command::Mongo.new ['--app', 'myapp']
    #@mongo.context()
    @mongo.stubs(:app).returns('myapp')
    @mongo.stubs(:display)
  end

  it "rescues exceptions when establishing a connection" do
    @mongo.expects(:error)
    Mongo::Connection.stubs(:new).raises(Mongo::ConnectionFailure)
    @mongo.send(:make_connection, URI.parse('mongodb://localhost'))
  end

  it "rejects urls without host" do
    @mongo.expects(:error)
    @mongo.send(:make_uri, 'test')
  end

  it "rescues URI parsing errors" do
    @mongo.expects(:error)
    @mongo.send(:make_uri, 'test:')
  end

  it "fixes mongohq addresses so it can connect from outside EC2" do
    uri = @mongo.send(:make_uri, 'mongodb://root:secret@hatch.local.mongohq.com/mydb')
    uri.host.should == 'hatch.mongohq.com'
  end
  
  #cleanup mocks after use. The integration tests that follow require the real thing
  after do
    mocha_verify
    mocha_teardown
  end
  
  describe "Integration test" do
    before do
      conn = Mongo::Connection.new
      @from     = conn.db('heroku-mongo-sync-origin')
      @from_uri = URI.parse('mongodb://localhost:27017/heroku-mongo-sync-origin')
      @to       = conn.db('heroku-mongo-sync-dest')
      @to_uri   = URI.parse('mongodb://localhost:27017/heroku-mongo-sync-dest')
      clear_collections
    end

    after do
      clear_collections
    end

    it "transfers records" do
      col = @from.create_collection('a')
      col.insert(:id => 1, :name => 'first')
      col.insert(:id => 2, :name => 'second')

      @mongo.send(:transfer, @from_uri, @to_uri)
      @to.collection_names.should include('a')
      @to.collection('a').find_one(:id => 1)['name'].should == 'first'
    end

    it "replaces existing data" do
      col1 = @from.create_collection('a')
      col1.insert(:id => 1, :name => 'first')
      col2 = @to.create_collection('a')
      col2.insert(:id => 2, :name => 'second')

      @mongo.send(:transfer, @from_uri, @to_uri)
      @to.collection('a').size.should == 1
    end
  end

  def clear_collections
    @from.collections.each { |c| c.drop unless sys_indexes?(c)}
    @to.collections.each { |c| c.drop unless sys_indexes?(c)}
  end

  def sys_indexes?(c)
    c.name == 'system.indexes'
  end
end
