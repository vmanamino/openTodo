require 'rails_helper'
include AuthHelper
include JsonHelper
include ExpiredKey

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }
  describe '#create' do
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with active valid key', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
      context 'user object status' do
        it_behaves_like 'create object status active', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
      end
      it 'renders newly created user in JSON format' do
        post :create, user: { username: 'newone', password: 'noone' }
        expect(response_in_json['user']['username']).to eq('newone')
      end
      context 'user status' do
        it_behaves_like 'create object status active', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
      end
      context 'attributes' do
        it 'serialized JSON excludes private attributes' do
          post :create, user: { username: 'newone', password: 'noone' }
          check_object(response_in_json, 'password', false)
          check_object(response_in_json, 'status', false)
        end
        it 'serialized JSON includes attribute id' do
          post :create, user: { username: 'newone', password: 'noone' }
          check_object(response_in_json, 'id', true)
        end
        it 'serialized JSON includes attribute username' do
          post :create, user: { username: 'newone', password: 'noone' }
          check_object(response_in_json, 'username', true)
        end
      end
      it 'username matches value given' do
        post :create, user: { username: 'newone', password: 'noone' }
        expect(response_in_json['user']['username']).to eq('newone')
      end
      context 'invalid attributes' do
        context 'empty attributes' do
          context '422' do
            it_behaves_like 'create invalid parameter returns 422', 'user', { username: 'newone', password: '' } # rubocop:disable all
            it_behaves_like 'create invalid parameter returns 422', 'user', { username: '', password: 'noone' } # rubocop:disable all
          end
          context 'json' do
            it_behaves_like 'create invalid parameter returns error in json', 'user', { username: 'newone', password: '' }, 'Password can\'t be blank' # rubocop:disable all
            it_behaves_like 'create invalid parameter returns error in json', 'user', { username: '', password: 'noone' }, 'Username can\'t be blank' # rubocop:disable all
          end
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'create unauthorized', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'create with expired key', 'user', { username: 'newone', password: 'noone' } # rubocop:disable all
    end
  end
  describe '#destroy' do
    before do
      @user_destroy = user
      @lists = create_list(:list, 5, user_id: @user_destroy.id)
    end
    context 'active valid key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with active valid key', 'user'
      context 'user object status' do
        it_behaves_like 'destroy action archives object', 'user'
      end
      context 'destroy dependents' do
        before do
          @keys = create_list(:api_key, 5, user_id: @user_destroy.id)
        end
        it_behaves_like 'destroy action archives object dependents', 'user', 'list', 5
        # plus one for helper key above equals six keys
        it_behaves_like 'destroy action archives object dependents', 'user', 'api_key', 6
      end
      context 'destroy grandchildren' do
        before do
          @lists.each do |list|
            create_list(:item, 5, list: list) # 5 lists times 5 items each equals 25 grandchildren
          end
        end
        it 'archives all items of lists belonging to user' do
          items = Item.where(status: 0).all
          expect(items.length).to eq(25)
          delete :destroy, id: @user_destroy.id
          items.reload
          items.each do |item|
            expect(item.status).to eq('archived')
          end
          items = Item.where(status: 0).all
          expect(items.length).to eq(0)
        end
      end
    end
    context 'user without key' do
      it_behaves_like 'destroy unauthorized', 'user'
    end
    context 'user with expired key' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with expired key', 'user'
    end
    context 'user unauthorized' do
      before do
        http_key_auth
      end
      it_behaves_like 'destroy with the wrong key', 'user'
      it_behaves_like 'destroy with the wrong key message', 'user', 'you are not the user'
    end
  end
end
