require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) {
    { email: 'school@test.com',
      password: 'testpassword',
      role: :school_admin
    }
  }
  let(:invalid_attributes) {
    { email: nil }
  }
  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end
    describe "GET #index" do
      it "assigns all users as @users" do
        user = FactoryBot.create :user
        get :index, params: {}
        expect(assigns(:users)).to include user
      end
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
      it "assigns the requested user as @user" do
        user = FactoryBot.create :user
        get :show, params: { id: user.to_param }
        expect(assigns(:user)).to eq(user)
      end
    end

    describe "GET #new" do
      it "assigns enrolled schools as @schools" do
        school = FactoryBot.create :school, enrolled: true
        get :new, params: {}
        expect(assigns(:schools)).to include school
      end
    end

    describe "GET #edit" do
      it "assigns enrolled schools as @schools" do
        user = FactoryBot.create :user
        school = FactoryBot.create :school, enrolled: true
        get :edit, params: { id: user.to_param }
        expect(assigns(:schools)).to include school
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new User" do
          expect {
            post :create, params: { user: valid_attributes }
          }.to change(User, :count).by(1)
        end

        it "assigns a newly created user as @user" do
          post :create, params: { user: valid_attributes }
          expect(assigns(:user)).to be_a(User)
          expect(assigns(:user)).to be_persisted
        end

        it "redirects to the created user" do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(User.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved user as @user" do
          post :create, params: { user: invalid_attributes }
          expect(assigns(:user)).to be_a_new(User)
        end

        it "re-renders the 'new' template" do
          post :create, params: { user: invalid_attributes }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          { email: 'new@test.com' }
        }

        it "updates the requested user" do
          user = FactoryBot.create :user
          put :update, params: { id: user.to_param, user: new_attributes }
          user.reload
          expect(user.email).to eq new_attributes[:email]
        end

        it "assigns the requested user as @user" do
          user = FactoryBot.create :user
          put :update, params: { id: user.to_param, user: new_attributes }
          expect(assigns(:user)).to eq(user)
        end

        it "redirects to the user" do
          user = FactoryBot.create :user
          put :update, params: { id: user.to_param, user: new_attributes }
          expect(response).to redirect_to(user)
        end
      end

      context "with invalid params" do
        it "assigns the user as @user" do
          user = FactoryBot.create :user
          put :update, params: { id: user.to_param, user: invalid_attributes }
          expect(assigns(:user)).to eq(user)
        end

        it "re-renders the 'edit' template" do
          user = FactoryBot.create :user
          put :update, params: { id: user.to_param, user: invalid_attributes }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested user" do
        user = FactoryBot.create :user
        expect {
          delete :destroy, params: { id: user.to_param }
        }.to change(User, :count).by(-1)
      end

      it "redirects to the users list" do
        user = FactoryBot.create :user
        delete :destroy, params: { id: user.to_param }
        expect(response).to redirect_to(users_url)
      end
    end
  end

  context "As a guest user" do
    before(:each) do
      sign_in_user(:guest)
    end
    describe "GET #index" do
      it "redirects to the root url" do
        get :index, params: {}
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
