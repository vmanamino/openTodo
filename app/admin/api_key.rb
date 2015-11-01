ActiveAdmin.register ApiKey do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  index do
    column 'Key ID', :id
    column 'Owner', :user_id do |api_key|
      api_key.user.username
    end
    column 'Owner ID', :user_id
    column 'Updated', :updated_at
    column 'Expires', :expires_at
    column :status
    actions
  end
end
