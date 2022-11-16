class ApplicationsController < ApplicationController

  def index
    applications = Application.all
    render json: applications.as_json(:except => [:id])
  end

  def show
    application = Application.find_by(token: params[:appToken])
    if application
      render json: application.as_json(:except => [:id])
    else
      render json: { error: 'No Application Found' }, status: 404
    end
  end

  def create
    if params[:name] and params[:name] != ""
      app = Application.new(
          name: params[:name],
          token: SecureRandom.base64(12),
        )
      if app.save
        render json: app.as_json(only: [:token, :name, :created_at])
      else
        render json: app.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Missing or Invalid Name' }, status: 400
    end
  end

  def update
    if params[:name] and params[:name] != ""
      application = Application.find_by(token: params[:appToken])
      if application
        if application.update(params.require(:application).permit(:name))
          render json: application.as_json(:except => [:id])
        else
          render json: application.errors, status: :unprocessable_entity
        end
      else
        render json: { error: 'No Application Found' }, status: 404
      end
    else
      render json: { error: 'Missing or Invalid Name' }, status: 400
    end
  end

end
