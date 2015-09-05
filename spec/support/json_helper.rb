module JsonHelper
   # method to check presence of attribute
  def check_each_object(collection, name = 'users', elements, attribute, boolean)
    counter = 0
    while counter < elements
      expect(collection[name][counter].key?(attribute)).to be boolean
      counter += 1
    end
  end
  # method to check presense of attribute in single user
  def check_object(object, name='user', attribute, boolean)
    expect(object[name].key?(attribute)).to be boolean
  end
end