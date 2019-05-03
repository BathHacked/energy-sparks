module Alerts
  module System
    class UpcomingHoliday
      # Temporary constant to match analytics
      TEMPLATE_VARIABLES = {
        holiday_start_date: {
          description: 'The date the next holiday is starting',
          units: :string
        },
        holiday_end_date: {
          description: 'The date the next holiday ends',
          units: :string
        },
        holiday_title: {
          description: 'The title of the event',
          units: :string
        }
      }.freeze

      def self.front_end_template_variables
        {
          'General' => TEMPLATE_VARIABLES
        }
      end

      def self.front_end_template_charts
        {}
      end

      def self.front_end_template_tables
        {}
      end

      def initialize(school:, today: Time.zone.today)
        @school = school
        @today = today
      end

      def report
        if @school.holiday_approaching?(today: @today)
          next_holiday = @school.next_holiday(today: @today)
          Adapters::Report.new(
            status: :good,
            rating: [0.0, (next_holiday.start_date - @today).to_i.to_f].max,
            summary: 'The school has a holiday approaching in their calendar',
            template_data: {
              holiday_start_date: next_holiday.start_date.strftime("%d/%m/%Y"),
              holiday_end_date: next_holiday.end_date.strftime("%d/%m/%Y"),
              holiday_title: next_holiday.title
            }
          )
        else
          Adapters::Report.new(
            status: :good,
            rating: 10.0,
            summary: 'The school has no holiday approaching',
          )
        end
      end
    end
  end
end
