class Api::ListsController < ApiController # rubocop:disable Style/ClassAndModuleChildren
  before_action :authenticated?, unless: :keyed_open
  before_action :authorization, only: [:create, :update, :destroy]

  def index
    user = get_key_user
    lists = List.visible_to(user)
    render json: lists, each_serializer: ListSerializer
  end

  def create
    user = get_key_user
    list = List.new(list_params)
    list.user_id = user.id
    if list.save
      render json: list
    else
      render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = get_key_user # assign user to variable for readability
    list = List.visible_to(user).find(params[:id])
    if list.update_attributes(list_params)
      render json: list
    else
      render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = get_key_user
    list = List.visible_to(user).find(params[:id])
    list.archived!
    render json: {}, status: :no_content
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  end

  private

  def list_params
    params.require(:list).permit(:name, :permissions)
  end
end
