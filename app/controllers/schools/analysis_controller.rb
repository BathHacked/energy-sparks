require 'dashboard'

class Schools::AnalysisController < ApplicationController
  before_action :set_school

  include SchoolAggregation
  include Measurements

  skip_before_action :authenticate_user!
  before_action :build_aggregate_school, except: [:analysis]
  before_action :set_nav
  before_action :set_measurement_options

  def analysis
    if @school.analysis?
      # Redirect to correct dashboard
      redirect_to school_analysis_tab_path(school: @school, tab: pages.keys.first)
    end
  end

  def show
    render_generic_chart_template
  end

private

  def build_aggregate_school
    # use for heat model fitting tabs
    @aggregate_school = aggregate_school
  end

  def set_nav
    @nav_array = pages.map do |page, config|
      { name: config[:name], page: page }
    end
  end

  def pages
    @school.configuration.analysis_charts_as_symbols
  end

  def render_generic_chart_template(extra_chart_config = {})
    extra_chart_config[:mpan_mprn] = params[:mpan_mprn] if params[:mpan_mprn].present?

    @measurement = measurement_unit(params[:measurement])

    @chart_config = { y_axis_units: @measurement }.merge(extra_chart_config)

    @title = title_and_chart_configuration[:name]
    @charts = title_and_chart_configuration[:charts]

    render :generic_chart_template
  end

  def title_and_chart_configuration
    tab = params[:tab].to_sym
    if [:test, :heating_model_fitting].include?(tab)
      DashboardConfiguration::DASHBOARD_PAGE_GROUPS[tab]
    else
      @school.configuration.analysis_charts_as_symbols[tab]
    end
  end

  def set_school
    @school = School.friendly.find(params[:school_id])
  end
end
