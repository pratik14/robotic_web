class AddTestCase
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def create
    return [422, user_not_found] unless user
    test_case = build_test
    build_events(test_case)
    if test_case.save
      return [200, 'Successfully Created']
    else
       reutrn [422, test_case.errors.full_messages]
    end
  end

  private

  def user
    @user = begin
      User.where(auth_token: params['auth_token']).first
    end
  end

  def user_not_found
    'No User found with given auth token'
  end

  def build_test
    user.test_cases.build(name: params['name'])
  end

  def build_events(test_case)
    params['key'].each do |index, attrs|
      keyword = Keyword.where(name: attrs['trigger']).first
      attrs = attrs.select{|k,v| events_attributes.include? k}
      attrs.merge!(keyword_id: keyword.try(:id))
      test_case.events.build(attrs)
    end
  end

  def events_attributes
    ['locator', 'value', 'text', 'expected', 'url', 'condition', 'order_number', 'message']
  end
end
