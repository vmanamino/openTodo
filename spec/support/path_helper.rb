require 'rails_helper'
module PathHelper
  def build_path(object, action)
    case object
      when 'list'
        case action
          when :index
            path = "/api/lists"
          when :create
            path = "/api/users/#{user.id}/lists"
          when :update
            path = "/api/users/#{user.id}/lists/#{@list_update.id}"
          when :destroy
            path = "/api/users/#{user.id}/lists/#{@list_destroy.id}"
        end
      when 'item'
        case action
          when :index
            path = "/api/items"
          when :create
            path = "/api/lists/#{list.id}/items"
          when :update
            path = "/api/lists/#{list.id}/items/#{@item_update.id}"
        end
    end
  end
end