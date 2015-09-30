class Api::ListsController < ApiController # rubocop:disable Style/ClassAndModuleChildren
  before_action :authenticated?, unless: :keyed_open

  def index
    lists = List.all
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
    list = List.find(params[:id])
    if list.update_attributes(list_params)
      render json: list
    else
      render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    list = List.find(params[:id])
    list.destroy
    render json: {}, status: :no_content
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  end

  private

  def list_params
    params.require(:list).permit(:name, :permissions)
  end
end
