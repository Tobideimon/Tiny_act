class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Avant chaque action d'un controller Devise (inscription/connexion),
  # on exécute la méthode ci-dessous.
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  # On autorise first_name et last_name à être enregistrés
  # UNIQUEMENT au moment de l'inscription (:sign_up).
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end
end
