ActiveAdmin.register Item do
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
    column :name
    column '#', :id
    column :done do |item|
      if item.done
        'Yes'
      elsif !item.done
        'No'
      else
        'invalid'
      end
    end
    column 'List', :list_id do |item|
      item.list.name
    end
    column 'List ID', :list_id
    column 'User', :list_id do |list|
      list.user.username
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :done
    end
    f.actions
  end

  controller do
    def item_params
      params.require(:item).permit(:name, :done)
    end
  end
end
