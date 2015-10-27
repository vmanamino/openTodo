module StatusHelper
  def check_status(collection, name, value='active')
  count = collection.length
  counter = 0
    while counter < counter
      expect(collection[name][counter]['status']).to eq(value)
      counter += 1
    end
  end
end