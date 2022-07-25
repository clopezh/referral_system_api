class UsersController < ApplicationController
  def index
    render json: User.where(active: true), except: [:active, :created_at, :updated_at]
  end

  def create
    # TODO: Verify if user has permissions to set role of the new user
    begin
      user = User.new(user_params)
      unless role_not_allowed
        if user.save
          render json: user, except: [:active, :created_at, :updated_at], status: :created
        else
          render json: {
            'message': 'Error while creating a new user',
            'errors': user.errors
          }, status: :unprocessable_entity
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error while creating a new user: #{e.message}")
      render json: {
        'message': 'Error while creating a new record',
        'errors': [e.message]
      }, status: :internal_server_error
    end
  end

  def show
    begin
      unless invalid_params_error
        user = User.find(params[:id])
        if user.active
          render json: user, status: :ok, except: [:active, :created_at, :updated_at]
        else
          render json: user.errors, status: :not_found
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: {
        'message': 'Record not found',
        'errors': [e.message]
      }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error while retrieving user #{e.message}")
      render json: {
        'message': 'Error while retrieving record',
        'errors': [e.message]
      }, status: :internal_server_error
    end
  end

  def update
    begin
      unless invalid_params_error || role_not_allowed
        user = User.find(params[:id])

        if user.update(user_params)
          render json: user, except: [:active, :created_at, :updated_at], status: :ok
        else
          render json: user.errors, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: {
        'message': 'Record not found',
        'errors': [e.message]
      }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error while retrieving user #{e.message}")
      render json: {
        'message': 'Error while retrieving record',
        'errors': [e.message]
      }, status: :internal_server_error
    end
  end

  def destroy
    begin
      unless invalid_params_error
        user = User.find(params[:id])
        if user.update(active: false)
          render json: {
            'message': 'User successfully deleted.'
          }, status: :ok
        else
          render json: user.errors, status: :unproccessable_entity
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: {
        'message': 'Record not found',
        'errors': [e.message]
      }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error while deleting user: #{e.message}")
      render json: {
        'message': 'Error while deleting user',
        'errors': [e.message]
      }, status: :internal_server_error
    end
  end

  private

  def user_params
    params.permit([:name, :email, :role_id])
  end

  def invalid_params_error
    unless params[:id].match? /\A\d+\z/
      message = 'ID is not a numeric value'
      Rails.logger.error(message)
      render json: {
        'message': 'Invalid parameter',
        'errors': [message]
      }, status: :unprocessable_entity
    end
  end

  def role_not_allowed
    message = 'Role not allowed'
    Rails.logger.error(message)
    render json: {
      'message': message,
      'errors': ['Creation of new admin users is not allowed']
    }, status: :forbidden if params[:role_id].to_i == 1
  end
end
