require 'rails_helper'
module PathHelper
  def build_path(object, action)
    case object
    when 'user'
      user_path(action)
    when 'list'
      list_path(action)
    when 'item'
      item_path(action)
    end
  end

  def user_path(action)
    case action
    when :index
      '/api/users'
    when :create
      '/api/users/'
    when :destroy
      "/api/users/#{@user_destroy.id}"
    end
  end

  def list_path(action)
    case action
    when :index
      '/api/lists'
    when :create
      "/api/users/#{user.id}/lists"
    when :update
      "/api/users/#{user.id}/lists/#{@list_update.id}"
    when :destroy
      "/api/users/#{user.id}/lists/#{@list_destroy.id}"
    end
  end

  def item_path(action)
    case action
    when :index
      '/api/items'
    when :create
      "/api/lists/#{list.id}/items"
    when :update
      "/api/lists/#{list.id}/items/#{@item_update.id}"
    end
  end
end
