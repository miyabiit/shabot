require 'test_helper'
require 'pp'

class Api::MyCorporationsControllerTest < ActionController::TestCase
  describe 'index' do
    it do
      @request.headers["Authorization"] = "Token TESTTOKEN"
      get :index, format: :json
      assert_response :success
    end
  end

  describe 'show' do
    it do
      @request.headers["Authorization"] = "Token TESTTOKEN"
      get :show, format: :json, id: MyCorporation.first.id
      assert_response :success
      Rails.logger.info PP.pp(JSON.parse(@response.body), '')
    end
  end
end
