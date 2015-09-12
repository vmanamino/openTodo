class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :done, :list_id
end
