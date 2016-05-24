module TargetModelFetching
  extend ActiveSupport::Concern
  
  included do
    class_attribute :_target_model
    before_action :set_title
  end

  class_methods do
    def target_model(model_name)
      self._target_model = case model_name
                           when Class
                             model_name
                           when String, Symbol
                             model_name.to_s.classify.constantize
                           end
    end
  end

  def set_title
    if self.class._target_model
      case params[:action].to_s
      when 'index'
        @casein_page_title = "#{self.class._target_model.model_name.human}一覧"
      when 'new'
        @casein_page_title = "新規#{self.class._target_model.model_name.human}"
      when 'show'
        @casein_page_title = "#{self.class._target_model.model_name.human}詳細"
      when 'update'
        @casein_page_title = "#{self.class._target_model.model_name.human}更新"
      end
    end
  end
end
