require 'rails_helper'

describe User do
  before do
    @user = create(:user)
  end
  it { should have_many(:lists) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }
end
