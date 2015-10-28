module StatusHelper
  def each_object_status(collection, name, value='active')
  count = collection.length
  counter = 0
    while counter < count
      # binding.pry
      expect(collection[name][counter]['status']).to eq(value)
      counter += 1
    end
  end
  def object_status(object, name, value='active')
    # binding.pry
    expect(object[name]['status']).to eq(value)
  end
end