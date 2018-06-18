require 'test_helper'
require 'pp'

class Api::PaymentsControllerTest < ActionController::TestCase
  describe 'index' do
    describe 'payment_date condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        get :index, format: :json, fromym: '201511', toym: '201512'
        assert_response :success
        results = JSON.parse(@response.body)
        assert results.all?{|r| ('2015-11'..'2015-12').include?(r['payment_date'][0..6]) }
        assert_not_equal 0, results.count
      end
    end

    describe 'project_name condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        get :index, format: :json, fromym: '200001', toym: '209901', project_name: 'テスト事業1'
        assert_response :success
        results = JSON.parse(@response.body)
        assert results.all?{|r| r['project']['name'] == 'テスト事業1' }
      end
    end

    describe 'project_category condition' do
      it do
        @request.headers["Authorization"] = "Token TESTTOKEN"
        category_name = projects(:test_1).category
        get :index, format: :json, fromym: '200001', toym: '209901', project_category: category_name
        assert_response :success
        results = JSON.parse(@response.body)
        assert results.all?{|r| r['project']['category'] == category_name }
      end
    end

    describe 'planned condition' do
      describe 'planned == true' do
        it do
          @request.headers["Authorization"] = "Token TESTTOKEN"
          get :index, format: :json, fromym: '200001', toym: '209901', planned: true
          assert_response :success
          results = JSON.parse(@response.body)
          assert results.all?{|r| r['planned'] }
        end
      end

      describe 'planned == false' do
        it do
          @request.headers["Authorization"] = "Token TESTTOKEN"
          get :index, format: :json, fromym: '200001', toym: '209901', planned: false
          assert_response :success
          results = JSON.parse(@response.body)
          assert results.all?{|r| !r['planned'] }
        end
      end
    end
  end

  describe 'show' do
    it do
      @request.headers["Authorization"] = "Token TESTTOKEN"
      get :show, format: :json, id: PaymentHeader.first.id
      assert_response :success
      Rails.logger.info PP.pp(JSON.parse(@response.body), '')
    end
  end
end
