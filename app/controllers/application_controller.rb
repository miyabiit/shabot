class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :handle_not_found_exception
  rescue_from ActiveRecord::RecordNotFound,   with: :handle_not_found_exception

  private
    def query_params
      {q: params[:q], c: params[:c], d: params[:d], page: params[:page]}
    end

    def handle_not_found_exception(ex)
      @exception = ex
      @status = :not_found
      logger.debug "#{ex.class.name} - #{ex.message}" if ex
      if ex.cause
        logger.debug "cause = #{ex.cause.message}"
        logger.debug " -#{ex.cause.backtrace.join("  \n")}"
      end
      @message = t('errors.messages.not_found')
      respond_to do |format|
        format.any { head @status }
        format.json { render json: {errors: [{message: @message}]}, status: @status }
        format.html { render 'errors/error', status: @status}
      end
    end
end
