ActiveAdmin.register List do
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
    column 'List', :name
    column '#', :id
    column :user_id do |list|
      list.user.username
    end
    column 'Created', :created_at
    column 'Updated', :updated_at
    column :permissions
    column :status
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :permissions
    end
    f.actions
  end

  controller do
    def list_params
      params.require(:list).permit(:name, :permissions)
    end
  end
end
