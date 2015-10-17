require 'rails_helper'
module PathHelper
  def build_path(object, action, user, list)
    case object
      when 'list'
        case action
          when :index
            lists = create_list(:list, 5, user: user)
            path = "/api/lists"
          when :create
            path = "/api/users/#{user.id}/lists"
          when :update, :destroy
            path = "/api/users/#{user.id}/lists/#{list.id}"
        end
      when 'item'
        case action
          when :index
            items = create_list(:item, 5, list: list)
            path = "/api/items"
          when :create
            path = "/api/lists/#{list.id}/items"
          when :update
            item = create(:item, list: list)
            path = "/api/lists/#{list.id}/items/#{item.id}"
        end
    end
  end
end