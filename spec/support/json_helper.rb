module JsonHelper
  # method to check presence of attribute in objects
  def check_each_object(collection, name = 'users', elements, attribute, boolean)
    counter = 0
    while counter < elements
      expect(collection[name][counter].key?(attribute)).to be boolean
      counter += 1
    end
  end
  # method to check presense of attribute in single object
  def check_object(object, name = 'user', attribute, boolean)
    expect(object[name].key?(attribute)).to be boolean
  end

  def response_in_json
    JSON.parse(response.body)
  end
end
