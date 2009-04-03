require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < Test::Unit::TestCase
  context "new get request" do
    setup do
      @base = mock('twitter base')
      @request = Twitter::Request.new(@base, :get, '/statuses/user_timeline.json', {:query => {:since_id => 1234}})
    end
    
    should "have base" do
      @request.base.should == @base
    end
    
    should "have method" do
      @request.method.should == :get
    end
    
    should "have path" do
      @request.path.should == '/statuses/user_timeline.json'
    end
    
    should "have options" do
      @request.options.should == {:query => {:since_id => 1234}}
    end
    
    should "have uri" do
      @request.uri.should == '/statuses/user_timeline.json?since_id=1234'
    end
    
    context "performing request for collection" do
      setup do
        response = mock('response', :body => fixture_file('user_timeline.json'))
        @base.expects(:get).returns(response)
        @object = @request.perform
      end

      should "return array of mashes" do
        @object.size.should == 20
        @object.each { |obj| obj.class.should be(Mash) }
        @object.first.text.should == 'Colder out today than expected. Headed to the Beanery for some morning wakeup drink. Latte or coffee...hmmm...'
      end
    end
    
    context "performing a request for a single object" do
      setup do
        response = mock('response', :body => fixture_file('status.json'))
        @base.expects(:get).returns(response)
        @object = @request.perform
      end

      should "return a single mash" do
        @object.class.should be(Mash)
        @object.text.should == 'Rob Dyrdek is the funniest man alive. That is all.'
      end
    end    
    
    context "with no query string" do
      should "not have any query string" do
        request = Twitter::Request.new(@base, :get, '/statuses/user_timeline.json')
        request.uri.should == '/statuses/user_timeline.json'
      end
    end
    
    context "with blank query string" do
      should "not have any query string" do
        request = Twitter::Request.new(@base, :get, '/statuses/user_timeline.json', :query => {})
        request.uri.should == '/statuses/user_timeline.json'
      end
    end
    
    should "have get shortcut to initialize and perform all in one" do
      Twitter::Request.any_instance.expects(:perform).returns(nil)
      Twitter::Request.get(@base, '/foo')
    end
    
    should "allow setting query string and headers" do
      response = mock('response', :body => '')
      @base.expects(:get).with('/statuses/friends_timeline.json?since_id=1234', {'Foo' => 'Bar'}).returns(response)
      Twitter::Request.get(@base, '/statuses/friends_timeline.json?since_id=1234', :headers => {'Foo' => 'Bar'})
    end
  end
  
  context "new post request" do
    setup do
      @base = mock('twitter base')
      @request = Twitter::Request.new(@base, :post, '/statuses/update.json', {:body => {:status => 'Woohoo!'}})
    end
    
    should "allow setting body and headers" do
      response = mock('response', :body => '')
      @base.expects(:post).with('/statuses/update.json', {:status => 'Woohoo!'}, {'Foo' => 'Bar'}).returns(response)
      Twitter::Request.post(@base, '/statuses/update.json', :body => {:status => 'Woohoo!'}, :headers => {'Foo' => 'Bar'})
    end
    
    context "performing request" do
      setup do
        response = mock('response', :body => fixture_file('status.json'))
        @base.expects(:post).returns(response)
        @object = @request.perform
      end

      should "return a mash of the object" do
        @object.text.should == 'Rob Dyrdek is the funniest man alive. That is all.'
      end
    end
    
    should "have post shortcut to initialize and perform all in one" do
      Twitter::Request.any_instance.expects(:perform).returns(nil)
      Twitter::Request.post(@base, '/foo')
    end
  end
  
end