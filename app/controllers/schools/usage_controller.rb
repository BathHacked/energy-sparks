module Schools
  class UsageController < ApplicationController
    include Measurements
    include SchoolAggregation


    load_and_authorize_resource :school

    skip_before_action :authenticate_user!, only: [:show]
    before_action :check_aggregated_school_in_cache, only: [:show]

    def show
      set_measurement_options
      @measurement = measurement_unit(params[:measurement])

      @supply = get_supply
      if @supply
        @chart_config = setup_chart_config(@school)
        render period
      else
        redirect_to school_path(@school), notice: 'No suitable supply could be found'
      end
    end

    private

    def setup_chart_config(school)
      {
        gas: {
          weekly: :calendar_picker_gas_week_chart,
          daily: :calendar_picker_gas_day_chart,
          earliest_reading:  school.earliest_reading_date("gas"),
          last_reading: school.last_reading_date("gas")
        },
        electricity: {
          weekly: :calendar_picker_electricity_week_example_comparison_chart,
          daily: :calendar_picker_electricity_day_chart,
          earliest_reading:  school.earliest_reading_date("electricity"),
          last_reading: school.last_reading_date("electricity")
        }
      }
    end

    def get_supply
      params[:supply].present? ? params[:supply].to_sym : supply_from_school
    end

    def supply_from_school
      case @school.fuel_types
      when :electric_and_gas, :electric_only then 'electricity'
      when :gas_only then 'gas'
      end
    end

    def period
      params[:period].present? ? params[:period].to_sym : :daily
    end
  end
end
