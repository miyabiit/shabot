require 'test_helper'
require 'pp'

class Api::ProjectsControllerTest < ActionController::TestCase
  describe 'index' do
    describe 'no condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        get :index, format: :json
        assert_response :success
      end
    end

    describe 'name condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        get :index, format: :json, name: 'テスト事業1'
        assert_response :success
        results = JSON.parse(@response.body)
        assert results.all?{|r| r['name'] == 'テスト事業1' }
      end
    end

    describe 'category condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        get :index, format: :json, name: projects(:test_1).category
        assert_response :success
        results = JSON.parse(@response.body)
        assert results.all?{|r| r['category'] == projects(:test_1).category }
      end
    end
  end

  describe 'show' do
    it do
      @request.headers["Authorization"] = "Token TESTTOKEN"
      get :show, format: :json, id: Project.first.id
      assert_response :success
      Rails.logger.info PP.pp(JSON.parse(@response.body), '')
    end
  end
end
