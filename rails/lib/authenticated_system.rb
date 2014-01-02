module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    def logged_in?
      !session[:profile].nil?
    end

    def login_required
      if !logged_in?
        redirect_to Mongo::Application.config.scat.auth_base_url+"pages/SCLogin?zone=SCAT&scid=7"
      end
    end

    def self.included(base)
      base.send :helper_method, :logged_in?
    end
end
