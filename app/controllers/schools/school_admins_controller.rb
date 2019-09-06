module Schools
  class SchoolAdminsController < ApplicationController
    include AlertContactCreator

    load_and_authorize_resource :school

    def new
      authorize! :manage_users, @school
      @school_admin = @school.users.school_admin.new
      authorize! :create, @school_admin
    end

    def create
      authorize! :manage_users, @school
      @school_admin = User.new_school_admin(@school, school_admin_params)
      if @school_admin.save
        create_alert_contact(@school, @school_admin) if auto_create_alert_contact?
        redirect_to school_users_path(@school)
      else
        render :new
      end
    end

    def edit
      @school_admin = @school.users.school_admin.find(params[:id])
      authorize! :edit, @school_admin
    end

    def update
      @school_admin = @school.users.school_admin.find(params[:id])
      authorize! :update, @school_admin
      if @school_admin.update(school_admin_params)
        redirect_to school_users_path(@school)
      else
        render :edit
      end
    end

    private

    def school_admin_params
      params.require(:user).permit(:name, :email)
    end
  end
end
