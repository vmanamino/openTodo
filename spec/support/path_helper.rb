require 'rails_helper'
module PathHelper
  def build_path(object, action, user, list)
    case object
      when 'list'
        case action
          when :update, :destroy
            #path = build_list_path(:exists, user, list)
            path = "/api/users/#{user.id}/lists/#{list.id}"
          when :create
            path = "/api/users/#{user.id}/lists"
            # path = build_list_path(:anew, user)
          when :index
            lists = create_list(:list, 5, user: user)
            # path = build_list_path(:collects, user)
            path = "/api/lists"
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