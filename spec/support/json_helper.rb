module JsonHelper
  # method to check presence of attribute in objects
  def check_each_object(collection, name = 'users', attribute, boolean)
    counter = 0
    while counter < collection.length
      expect(collection[name][counter].key?(attribute)).to be boolean
      counter += 1
    end
  end
  # method to check presense of attribute in single object
  def check_object(object, name = 'user', attribute, boolean)
    expect(object[name].key?(attribute)).to be boolean
  end

  def object_owner(collection, model, name, user) # rubocop:disable Metrics/AbcSize
    counter = 0
    my_model = Object.const_get(model)
    while counter < collection[name].length
      id = collection[name][counter]['id']
      object = my_model.find(id)
      owner = object.user
      expect(owner.id).to eq(user.id)
      counter += 1
    end
  end

  def response_in_json
    # binding.pry
    JSON.parse(response.body)
  end
end
