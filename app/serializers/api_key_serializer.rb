class ApiKeySerializer < ActiveModel::Serializer
  attributes :access_token, :expires_at
end
