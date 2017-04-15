require 'spec_helper'

describe AddTestCase do

  let(:params) do
    {"key"=>{"0"=>{"url"=>"http://localhost:3000/", "time"=>"0", "trigger"=>"Open Browser", "message"=>"Open Browser", "order_number"=>"1"},
    "1"=>{"trigger"=>"Set Window Size", "time"=>"21", "message"=>"Set window size", "order_number"=>"2"},
    "2"=>{"time"=>"1492239969914", "locator"=>"//div[1]/div[1]/div[1]/div[1]/ul[1]/li[3]/a[1]", "value"=>"Sign In", "message"=>"change input to Sign In", "trigger"=>"Click Element", "order_number"=>"3"},
    "3"=>{"trigger"=>"Wait For Condition", "condition"=>"return document.readyState == 'complete'", "time"=>"1492239970312", "message"=>"Go to pagehttp://localhost:3000/users/sign_in", "order_number"=>"4"},
    "4"=>{"time"=>"1492239971585", "locator"=>"//input[@id=\"user_password\"]", "text"=>"josh12345", "trigger"=>"Input Text", "order_number"=>"5"},
    "5"=>{"time"=>"1492239975975", "locator"=>"//input[@id=\"user_email\"]", "text"=>"a@a.com", "trigger"=>"Input Text", "order_number"=>"6"},
    "6"=>{"time"=>"1492239979013", "locator"=>"//input[@id=\"user_password\"]", "text"=>"josh123", "trigger"=>"Input Text", "order_number"=>"7"},
    "7"=>{"time"=>"1492239979023", "locator"=>"//div[1]/div[4]/div[1]/form[1]/div[4]/input[1]", "value"=>"Log in", "message"=>"change input to Log in", "trigger"=>"Click Element", "order_number"=>"8"},
    "8"=>{"trigger"=>"Wait For Condition", "condition"=>"return document.readyState == 'complete'", "time"=>"1492239981766", "message"=>"Go to pagehttp://localhost:3000/showroom", "order_number"=>"9"}},
    "name"=>"hey"}
  end

  context "#create" do
    context "auth_token is invalid" do
      it 'return value' do
        expect(AddTestCase.new(params).create).to eq([422, 'No User found with given auth token'])
      end
    end

    context 'auth_token is valid' do
      it 'return value' do
        user = create(:user)
        new_params = params.merge!('auth_token' => user.auth_token)
        expect(AddTestCase.new(new_params).create).to eq([200, "Successfully Created"])

        test_case = TestCase.last
        expect(test_case.name).to eq('hey')
        expect(test_case.events.size).to eq(9)
      end
    end
  end
end
