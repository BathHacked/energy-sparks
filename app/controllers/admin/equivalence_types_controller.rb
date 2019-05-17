module Admin
  class EquivalenceTypesController < AdminController
    load_and_authorize_resource


    def index
    end

    def new
      @content = EquivalenceTypeContentVersion.new
    end

    def create
      @content = @equivalence_type.content_versions.new(content_params[:content])
      if @equivalence_type.update_with_content!(equivalence_type_params, @content)
        redirect_to admin_equivalence_types_path(@equivalence_type), notice: 'Equivalence created'
      else
        render :new
      end
    end

    def edit
      @content = @equivalence_type.current_content
    end

    def update
      @content = @equivalence_type.content_versions.new(content_params[:content])
      if @equivalence_type.update_with_content!(equivalence_type_params, @content)
        redirect_to admin_equivalence_types_path, notice: 'Equivalence type updated'
      else
        render :edit
      end
    end

  private

    def equivalence_type_params
      params.require(:equivalence_type).permit(:meter_type, :time_period)
    end

    def content_params
      params.require(:equivalence_type).permit(
        content: [:equivalence]
      )
    end
  end
end
