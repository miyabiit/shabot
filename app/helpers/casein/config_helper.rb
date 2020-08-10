module Casein
  module ConfigHelper
    
    # Name of website or client — used throughout Casein.
    def casein_config_website_name
      'SHABOT'
    end

    # Filename of logo image. Ideally, it should be a transparent PNG around 140x30px
    def casein_config_logo
      'shabot.png'
    end

    # The server hostname where Casein will run
    def casein_config_hostname
      if Rails.env.production?
        'http://shabot.shallontec.biz'
      elsif Rails.env.production_8woods?
        'http://8woods.shallontec.biz'
      elsif Rails.env.production_oosumiff?
        'http://shabot.oosumi-ff.jp'
      else
        'http://localhost:3000'
      end
    end

    # The sender address used for email notifications
    def casein_config_email_from_address
      'donotreply@shallontec.biz'
    end
  
    # The initial page the user is shown after they sign in or click the logo. Probably this should be set to the first tab.
    # Do not point this at casein/index!
    def casein_config_dashboard_url
      #url_for :controller => :casein, :action => :blank
      url_for :controller => :accounts
    end
  
    # A list of stylesheets to include. Do not remove the core casein/casein, but you can change the load order, if required.
    def casein_config_stylesheet_includes
      %w[casein/casein casein/custom]
    end
  
    # A list of JavaScript files to include. Do not remove the core casein/casein, but you can change the load order, if required.
    def casein_config_javascript_includes
      %w[casein/casein casein/custom]
    end
    
  end
end
