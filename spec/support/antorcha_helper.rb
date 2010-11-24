

module AntorchaHelper
  
  %w[
    antorcha message step
  ].each do |model|
    self.class_eval <<-RUBY
      def mock_#{model} name = :default
        @mock_#{model} ||= {}
        @mock_#{model}[name] ||= mock_model(#{model.classify})
      end
      
      def mock_#{model.pluralize} name = :default
        @mock_#{model.pluralize} ||= {}
        @mock_#{model.pluralize}[name] ||= [mock_#{model}(name), mock_#{model}(name)]
      end
    RUBY
  end
  
  %w[message_delivery transaction_cancellation].each do |job|
    self.class_eval <<-RUBY
      def stub_new_#{job}_job
        Jobs::#{job.classify}Job.stub(:new => mock_#{job}_job)
      end
  
      def mock_#{job}_job
        @mock_#{job}_job ||= mock(Jobs::#{job.classify}Job)
      end
    RUBY
  end

  %w[worker].each do |model|
    self.class_eval <<-RUBY
      def stub_new_#{model}
        #{model.classify}.stub(:new => mock_#{model})
      end
  
      def mock_#{model}
        @mock_#{model} ||= mock(#{model.classify})
      end
      
      def mock_#{model.pluralize}
        @mock_#{model.pluralize} ||= [mock_#{model}, mock_#{model}]
      end
    RUBY
  end
  
  def turn_of_devise_and_cancan_because_this_is_specced_in_the_ability_spec
    controller.stub \
      :authenticate_user! => nil,
      :authorize! => nil
  end

  def have_devise_before_filter
    have_before_filter(:authenticate_user!)
  end
  
  def sign_in_user type = 'communicator', options = {}
    @user = User.create!(:email => "test@example.com", :username => "test", :password => "qwerty", :password_confirmation => "qwerty")
    @user.update_attribute :user_type, type.to_s

    @user.stub :castables => castables_for(options.delete(:as)) if options[:as]

    sign_in @user
    stub_current_user_so_that_cancan_uses_the_mock_for_testing_abilities
  end

  def view_as_user type = 'communicator', option = {}
    @user = User.create!(:email => "test@example.com", :username => "test", :password => "qwerty", :password_confirmation => "qwerty")
    @user.update_attribute :user_type, type.to_s

    @user.stub :castables => castables_for(options.delete(:as)) if options[:as]

    stub_current_user_so_that_cancan_uses_the_mock_for_testing_abilities
  end

  def stub_current_user_so_that_cancan_uses_the_mock_for_testing_abilities
    controller.stub :current_user => @user if self.respond_to?(:controller)
    @controller.stub :current_user => @user if @controller
  end
  
  def castables_for roles
    Array(roles).map {|title| mock(Castable, :role => mock(Role, :title => title.to_s))} 
  end
  
  def act_as who
    raise "THIS HELPER IS DEPRECATED"
    # session[:user] = [who]
    # session[:user] = sign_in_user.id
  end

  def mock_search
    @mock_search ||= mock(Searchlogic::Search, :id => nil)
  end

  def stub_search mocked_models
    mocked_models.first.class.stub :search => mock_search
    mock_search.stub :all => mocked_models
  end

  def stub_new(mocked_model, params = nil)
    s = mocked_model.class.stub(:new)
    s = s.with(params) if params
    s.and_return(mocked_model)
  end

  def stub_create(mocked_model, params = nil)
    s = mocked_model.class.stub(:create)
    s = s.with(params) if params
    s.and_return(mocked_model)
  end

  def stub_update(mocked_model, succes = true, params = nil)
    s = mocked_model.stub(:update_attributes)
    s = s.with(params) if params
    s.and_return(succes)
  end

  def stub_successful_update(mocked_model, params = nil)
    stub_update(mocked_model, true, params)
  end

  def stub_unsuccessful_update(mocked_model, params = nil)
    stub_update(mocked_model, false, params)
  end

  def stub_new_on(finder, mocked_model, params = nil)
    s = finder.stub(:new)
    s = s.with(params) if params
    s.and_return(mocked_model)
  end
  
  def stub_build_on(finder, mocked_model, params = nil)
    s = finder.stub(:build)
    s = s.with(params) if params
    s.and_return(mocked_model)
  end

  def stub_find_on(finder, mocked_model, params = nil)
    s = finder.stub(:find)
    s = s.with(params) if params
    s.and_return(mocked_model)
  end

  def stub_all(mocked_model_or_models)
    case mocked_model_or_models
    when Array:
      mocked_model = mocked_model_or_models.first
      mocked_models = mocked_model_or_models
    when Object:
      mocked_model = mocked_model_or_models
      mocked_models = [mocked_model]
    end
    mocked_model.class.stub(:all => mocked_models)
  end

  def stub_find(mocked_model)
    mocked_model.class.stub(:find).with(mocked_model.to_param).and_return(mocked_model)
  end
  
  def stub_find_by model, options
    scope = options.delete :on
    scope ||= model.class

    model.stub options unless model.nil?

    options.each do |key, value|
      scope.stub("find_by_#{key}").with(value).and_return(model)
    end
  end

  def stub_find_by! model, hash
    model.stub hash
    hash.each do |key, value|
      model.class.stub("find_by_#{key}!").with(value).and_return(model)
    end
  end

  def stub_successful_save_for(mocked_model)
    mocked_model.stub(:save => true)
  end

  def stub_unsuccessful_save_for(mocked_model)
    mocked_model.stub(:save => false)
  end

  def stub_authorize!
    controller.stub :authorize! => nil
  end
  
  def expect_authorize how, what
    controller.should_receive(:authorize!).with(how, what)
  end

  def debug(x)
    puts "<div class=\"debug\" style=\"background: #ddd; padding: 1em;\"><pre>"
    puts ERB::Util.html_escape(x)
    puts "</pre></div>"
  end

  def debunk(x)
    puts "<div class=\"debug\" style=\"background: #ddd; padding: 1em;\"><pre>"
    puts ERB::Util.html_escape(x)
    puts "</pre></div>"
  end
  
  
  Spec::Matchers.define :have_before_filter do |expected|
    match do |actual|
      actual.class.before_filters.include?(expected)
    end

    failure_message_for_should do |actual|
      "expected that #{actual} would have a before filter #{expected}"
    end

    failure_message_for_should_not do |actual|
      "expected that #{actual} would not have before filter #{expected}"
    end

    description do
      "have before filter #{expected}"
    end
  end
  
  
  def stub_render_partial
    template.stub(:render).with(hash_including(:partial => anything())).and_return('')
  end
  
  def should_render_partial name
    template.should_receive(:render).with(hash_including(:partial => name))
  end
  
  
  def stub_authenticated_soap_service
    @controller = SoapController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    User.create! \
      :username => 'aap', :email => 'aap@example.com',
      :password => 'nootjes', :password_confirmation => 'nootjes'

    @warden = mock('warden')
    @controller.stub :warden => @warden
    @warden.stub :set_user => nil
  end
  
end

