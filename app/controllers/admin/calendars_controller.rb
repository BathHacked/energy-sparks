module Admin
  class CalendarsController < AdminController
    load_and_authorize_resource

    def index
      @national_calendars = Calendar.national.includes(:schools).order(:title)
      @regional_calendars = Calendar.regional.includes(:schools).order(:title)
      @school_calendars = Calendar.school.includes(:schools).order('schools.name')
    end

    def new
      @calendar.calendar_type = :regional
    end

    def create
      terms = EnergySparks::CsvLoader.from_text(params.fetch(:terms) {{}}.fetch(:csv) {''})
      based_on_calendar = Calendar.find(calendar_params[:based_on_id])

      @calendar = CalendarFactory.new(existing_calendar: based_on_calendar, title: calendar_params[:title], calendar_type: Calendar.calendar_types[calendar_params[:calendar_type]]).build

      if @calendar.save
        # New create terms and holidays from hash
        CalendarTermFactory.new(@calendar, terms).create_terms
        redirect_to admin_calendars_path, notice: 'Calendar created'
      else
        render :new
      end
    end

  private

    def calendar_params
      params.require(:calendar).permit(:title, :description, :based_on_id, :calendar_type)
    end
  end
end