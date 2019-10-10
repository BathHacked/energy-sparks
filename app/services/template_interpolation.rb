require 'mustache'
require 'closed_struct'

class TemplateInterpolation
  def initialize(object, with_objects: {}, proxy: [])
    @object = object
    @with_objects = with_objects
    @proxy = proxy
  end

  def interpolate(*fields, with: {})
    base_methods = { template_variables: with }.merge(@with_objects)
    with_proxied_objects = @proxy.inject(base_methods) do |collection, field|
      collection[field] = @object.send(field)
      collection
    end
    templated = fields.inject(with_proxied_objects) do |collection, field|
      collection[field] = process(@object.send(field) || "", with)
      collection
    end
    ClosedStruct.new(templated)
  end

  def variables(*fields)
    from_templates = fields.inject([]) do |variables, field|
      variables + get_variables(@object.send(field))
    end
    from_templates.uniq.map {|variable| variable.gsub('gbp', '£') }
  end

private

  def process(template, variables)
    Mustache.render(template_as_string(template), variables)
  end

  def get_variables(template)
    mustache = Mustache.new
    mustache.template = template_as_string(template)
    mustache.template.tags
  end

  def template_as_string(template)
    template.is_a?(ActionText::RichText) ? template.body.to_s : template
  end
end
