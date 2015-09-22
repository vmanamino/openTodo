require 'rails_helper'

describe ApiKey do
  before do
    @api_key = create(:api_key)
  end
  it { should belong_to(:user) }
  it 'access_token is unique' do # could not use shoulda see https://github.com/thoughtbot/shoulda-matchers/issues/371#issuecomment-26606988
    @keys = create_list(:api_key, 5)
    duplicate_list = []
    duplicate = 0
    counter = 0
    @keys.each do |key| # take each key to push in to duplicate list
      if counter == 0 # push first key into duplicate list
        duplicate_list.push(key)
      else # each subsequent key will be checked against all of the duplicate list keys for a match
        duplicate_list.each do |duplicate_list_key|
          # if match, then duplicate is incremented
          duplicate += 1 if key.access_token == duplicate_list_key.access_token
        end
        duplicate_list.push(key) # push subsequent keys into duplicate list
      end
      counter += 1 # ensures that condition is false after first key
    end
    expect(duplicate).to eq(0) # no matches
    expect(duplicate_list).to eq(@keys) # same items are being compared
  end
  it 'access_token is not nil' do
    expect(@api_key.access_token).not_to be nil
  end
  it 'access_token is not empty' do
    expect(@api_key.access_token.empty?).to be false
  end
  it 'expires_at is time' do
    expect(@api_key.expires_at.is_a?(Time)).to be true
  end
  it 'expires has default value' do
    expect(@api_key.expires_at).not_to be nil
  end
end
