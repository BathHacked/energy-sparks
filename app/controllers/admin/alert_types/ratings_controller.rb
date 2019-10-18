module Admin
  module AlertTypes
    class RatingsController < AdminController
      load_and_authorize_resource :alert_type

      before_action :set_template_variables, except: [:index]
      before_action :set_available_charts, except: [:index]

      def index
        @ratings = @alert_type.ratings.order(rating_from: :asc, rating_to: :asc, description: :asc)
      end

      def new
        @rating = @alert_type.has_ratings? ? AlertTypeRating.new : AlertTypeRating.new(rating_from: 0, rating_to: 10)
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
        @example_variables = load_example_variables(@rating)
      end

      def update
        @rating = @alert_type.ratings.find(params[:id])
        @content = @rating.content_versions.new(content_params[:content])
        if @rating.update_with_content!(rating_params, @content)
          redirect_to admin_alert_type_ratings_path(@alert_type), notice: 'Content updated'
        else
          @example_variables = load_example_variables(@rating)
          render :edit
        end
      end

    private

      def rating_params
        params.require(:alert_type_rating).permit(
          :description, :rating_from, :rating_to,
          :sms_active, :email_active, :find_out_more_active,
          :teacher_dashboard_alert_active, :pupil_dashboard_alert_active,
          :public_dashboard_alert_active, :management_dashboard_alert_active,
          :management_priorities_active
        )
      end

      def content_params
        params.require(:alert_type_rating).permit(
          content: [:colour] + AlertTypeRatingContentVersion.template_fields + AlertTypeRatingContentVersion.timing_fields + AlertTypeRatingContentVersion.weighting_fields
        )
      end

      def set_template_variables
        @template_variables = @alert_type.cleaned_template_variables
      end

      def set_available_charts
        @available_charts = @alert_type.available_charts
        @available_charts << ["None", :none]
      end

      def load_example_variables(rating)
        example_alert = rating.alert_type.alerts.where(displayable: true).rating_between(rating.rating_from, rating.rating_to).order(created_at: :desc).first
        if example_alert
          @example_variables = example_alert.template_variables
        end
      end
    end
  end
end
