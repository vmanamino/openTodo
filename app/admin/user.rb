ActiveAdmin.register User do
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
    column 'Name', :username
    column '#', :id
    column 'Created', :created_at
    column :status
    actions
  end

  form do |f|
    f.inputs do
      f.input :username
      f.input :password
    end
    f.actions
  end
  controller do
    def user_params
      params.require(:user).permit(:username, :password)
    end
  end
end
