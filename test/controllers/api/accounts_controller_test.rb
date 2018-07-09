require 'test_helper'
require 'pp'

class Api::AccountsControllerTest < ActionController::TestCase
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
      get :show, format: :json, id: Account.first.id
      assert_response :success
      Rails.logger.info PP.pp(JSON.parse(@response.body), '')
    end
  end
end
