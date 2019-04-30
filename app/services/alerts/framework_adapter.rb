require 'dashboard'

module Alerts
  class FrameworkAdapter
    def initialize(alert_type, school, analysis_date = nil, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date || calculate_analysis_date
    end

    def analyse
      report = adapter_class(@alert_type).new(alert_type: @alert_type, school: @school, analysis_date: @analysis_date, aggregate_school: @aggregate_school).report
      build_alert(report)
    end

  private

    def adapter_class(alert_type)
      if alert_type.system?
        Adapters::SystemAdapter
      else
        Adapters::AnalyticsAdapter
      end
    end

    def calculate_analysis_date
      return Time.zone.today if @alert_type.fuel_type.nil?
      @aggregate_school.analysis_date(@alert_type.fuel_type)
    end

    def build_alert(analysis_report)
      Alert.new(
        school_id:      @school.id,
        alert_type_id:  @alert_type.id,
        run_on:         @analysis_date,
        status:         analysis_report.status,
        summary:        analysis_report.summary,
        data:           data_hash(analysis_report)
      )
    end

    def data_hash(analysis_report)
      {
        help_url:      analysis_report.help_url,
        detail:        analysis_report.detail,
        rating:        analysis_report.rating,
        template_data: analysis_report.template_data,
        chart_data:    analysis_report.chart_data,
        table_data:    analysis_report.table_data
      }
    end
  end
end
