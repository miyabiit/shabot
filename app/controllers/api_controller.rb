class ApiController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  rescue_from Exception, with: :handle_500
  rescue_from ActiveRecord::RecordNotFound, with: :handle_404

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      if token.present?
        @api_user = Casein::AdminUser.find_by(api_token: token)
      end
    end
  end

  def api_user
    @api_user
  end

  def handle_500(ex)
    print_exception(ex)
    head :internal_server_error
  end

  def handle_404(ex)
    print_exception(ex)
    head :not_found
  end

  def print_exception(ex)
    if ex
      logger.warn ex.message
      if ex.try(:cause)
        logger.warn "#{ex.cause.message}:"
        if ex.try(:cause).try(:backtrace)
          logger.warn " -#{ex.cause.backtrace.join("  \n")}"
        end
      end
    end
  end
end
