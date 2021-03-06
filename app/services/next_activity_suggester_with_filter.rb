class NextActivitySuggesterWithFilter
  NUMBER_OF_SUGGESTIONS = 6

  def initialize(school, filter)
    @school = school
    @filter = filter
  end

  def suggest_from_activity_history
    suggestions = []
    if @school.activities.empty?
      get_initial_suggestions(suggestions)
    else
      get_suggestions_based_on_last_activity(suggestions)
    end

    #ensure minimum of five suggestions
    top_up_if_not_enough_suggestions(suggestions) if suggestions.length < NUMBER_OF_SUGGESTIONS

    suggestions
  end

  def suggest_from_programmes
    scope = @school.programme_activity_types.where('programmes.status = ? AND programme_activities.activity_id IS NULL', Programme.statuses[:started]).order('programme_activities.position ASC').group('activity_types.id, programme_activities.position')
    activity_type_filter = ActivityTypeFilter.new(query: @filter.query, school: @school, scope: scope)
    activity_type_filter.activity_types
  end

  def suggest_from_find_out_mores
    content = @school.latest_content
    if content
      scope = content.find_out_more_activity_types
      activity_type_filter = ActivityTypeFilter.new(query: @filter.query, school: @school, scope: scope)
      activity_type_filter.activity_types
    else
      ActivityType.none
    end
  end

private

  def get_initial_suggestions(suggestions)
    ActivityTypeSuggestion.initial.order(:id).each do |ats|
      suggestions << ats.suggested_type if suggestion_can_be_added?(ats.suggested_type, suggestions)
    end
  end

  def get_suggestions_based_on_last_activity(suggestions)
    last_activity_type = @school.activities.order(:created_at).last.activity_type
    activity_type_filter = ActivityTypeFilter.new(query: @filter.query.merge(not_completed_or_repeatable: true), school: @school, scope: last_activity_type.suggested_types)
    activity_type_filter.activity_types.each do |suggested_type|
      if suggestion_can_be_added?(suggested_type, suggestions)
        suggestions << suggested_type
      end
    end
  end

  def top_up_if_not_enough_suggestions(suggestions)
    more = @filter.activity_types.random_suggestions.sample(NUMBER_OF_SUGGESTIONS - suggestions.length)
    suggestions.concat(more.select {|suggestion| suggestion_can_be_added?(suggestion, suggestions)})
  end

  def suggestion_can_be_added?(suggested_type, suggestions)
    @filter.activity_types.include?(suggested_type) && !suggestions.include?(suggested_type)
  end
end
