require 'rails_helper'
module PathHelper
  def build_path(object, action)
    case object
    when 'list'
      case action
      when :index
        "/api/lists"
      when :create
        "/api/users/#{user.id}/lists"
      when :update
        "/api/users/#{user.id}/lists/#{@list_update.id}"
      when :destroy
        "/api/users/#{user.id}/lists/#{@list_destroy.id}"
      end
    when 'item'
      case action
      when :index
        "/api/items"
      when :create
        "/api/lists/#{list.id}/items"
      when :update
        "/api/lists/#{list.id}/items/#{@item_update.id}"
      end
    end
  end
end