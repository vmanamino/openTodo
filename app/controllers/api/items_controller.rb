class Api::ItemsController < ApiController # rubocop:disable Style/ClassAndModuleChildren
  before_action :authenticated?, unless: :keyed_open

  def index
    user = get_key_user
    items = Item.owned(user)
    render json: items, each_serializer: ItemSerializer
  end

  def create
    list = List.find(params[:list_id])
    item = Item.new(item_params)
    item.list_id = list.id
    if item.save
      render json: item
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update_attributes(item_params)
      render json: item
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def item_params
    params.require(:item).permit(:name, :done)
  end
end
