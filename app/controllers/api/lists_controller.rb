class Api::ListsController < ApiController # rubocop:disable Style/ClassAndModuleChildren
  before_action :authenticated?, unless: :keyed_open
  def index
    user = get_key_user
    lists = List.visible_to(user)
    render json: lists, each_serializer: ListSerializer
  end

  def create
    user = User.find(params[:user_id])
    list = List.new(list_params)
    list.user_id = user.id
    if list.save
      render json: list
    else
      render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    list = List.own(params[:id], get_key_user)
    if list
      if list.update_attributes(list_params)
        render json: list
      else
        render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: {}, status: :not_found
    end
  end

  def destroy
    list = List.find(params[:id])
    key_owner = get_key_user
    record_owner = User.find(list.user.id)
    if key_owner.id == record_owner.id
      list.destroy
      render json: {}, status: :no_content
    else
      ActiveRecord::RecordNotFound
      render json: {}, status: :not_found
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :permissions)
  end
end
