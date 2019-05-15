module Admin
  module AlertTypes
    class RatingsController < AdminController
      load_and_authorize_resource :alert_type

      before_action :set_template_variables, except: [:index]
      before_action :set_available_charts, except: [:index]

      def index
        @ratings = @alert_type.ratings.order(rating_from: :asc)
      end

      def new
        @rating = AlertTypeRating.new
        @content = AlertTypeRatingContentVersion.new
      end

      def create
        @rating = @alert_type.ratings.new
        @content = @rating.content_versions.new(content_params[:content])
        if @rating.update_with_content!(rating_params, @content)
          redirect_to admin_alert_type_ratings_path(@alert_type), notice: 'Content created'
        else
          render :new
        end
      end

      def edit
        @rating = @alert_type.ratings.find(params[:id])
        @content = @rating.current_content
      end

      def update
        @rating = @alert_type.ratings.find(params[:id])
        @content = @rating.content_versions.new(content_params[:content])
        if @rating.update_with_content!(rating_params, @content)
          redirect_to admin_alert_type_ratings_path(@alert_type), notice: 'Content updated'
        else
          render :edit
        end
      end

    private

      def rating_params
        params.require(:alert_type_rating).permit(
          :description, :rating_from, :rating_to,
          :sms_active, :email_active, :find_out_more_active,
          :teacher_dashboard_alert_active, :pupil_dashboard_alert_active
        )
      end

      def content_params
        params.require(:alert_type_rating).permit(
          content: [:colour] + AlertTypeRatingContentVersion.template_fields + AlertTypeRatingContentVersion.timing_fields
        )
      end

      def set_template_variables
        @template_variables = @alert_type.cleaned_template_variables
      end

      def set_available_charts
        @available_charts = @alert_type.available_charts
        @available_charts << ["None", :none]
      end
    end
  end
end
