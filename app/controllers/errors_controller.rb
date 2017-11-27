class ErrorsController < ActionController::Base
  layout 'application'

  def render_404
    @status = :not_found
    @message = t('errors.messages.not_found')
    respond_to do |format|
      format.json { render json: {errors: [{message: @message}]}, status: @status }
      format.html { render 'errors/error', status: @status}
    end
  end
end
