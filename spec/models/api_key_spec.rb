require 'rails_helper'

describe ApiKey do
  before do
    @api_key = create(:api_key)
  end
  it { should belong_to(:user) }
  it 'access_token is unique' do # could not use shoulda see https://github.com/thoughtbot/shoulda-matchers/issues/371#issuecomment-26606988
    @api_key_two = create(:api_key)
    expect(@api_key.access_token).not_to eq(@api_key_two.access_token)
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