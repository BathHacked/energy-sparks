module Schools
  class ActivityTypesController < ApplicationController
    load_resource :school
    load_and_authorize_resource

    def index
      @activity_types = @activity_types.includes(:activity_category).order("activity_categories.name", :name)
    end

    def show
      @recorded = Activity.where(activity_type: @activity_type).count
      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
      @content = TemplateInterpolation.new(
        @activity_type,
        render_with: SchoolTemplate.new(@school)
      ).interpolate(
        :school_specific_description_or_fallback
      )
    end
  end
end
