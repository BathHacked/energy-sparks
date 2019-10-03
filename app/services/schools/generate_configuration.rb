module Schools
  class GenerateConfiguration
    def initialize(school)
      @school = school
      @aggregated_meter_collection = AggregateSchoolService.new(school).aggregate_school
    end

    def generate
      configuration = Schools::Configuration.where(school: @school).first_or_create

      fuel_configuration = GenerateFuelConfiguration.new(@aggregated_meter_collection).generate
      configuration.update!(fuel_configuration: fuel_configuration)

      gas_dashboard_chart_type = GenerateGasDashboardChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate
      configuration.update!(gas_dashboard_chart_type: gas_dashboard_chart_type)

      analysis_chart_configuration = GenerateAnalysisChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration)

      analysis_charts = analysis_chart_configuration.generate
      configuration.update!(analysis_charts: analysis_charts)

      pupil_analysis_charts = analysis_chart_configuration.generate([:pupil_analysis_page])
      configuration.update!(pupil_analysis_charts: pupil_analysis_charts)

      configuration
    end
  end
end
