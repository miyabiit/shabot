module ApplicationHelper
  %W(text_field text_area date_select).each do |input_name|
    define_method("casein_#{input_name}_i18n", ->(form, method, options = {}) {
      if form.object
        options[:casein_label] ||= form.object.class.human_attribute_name method
      end
      send("casein_#{input_name}", form, form.object, method, options)
    })
  end

  def casein_select_i18n(form, method, collection, options={})
    if form.object
      options[:casein_label] ||= form.object.class.human_attribute_name method
    end
    casein_select(form, form.object, method, collection, options)
  end

  def casein_collection_select_i18n(form, method, collection, options={})
    options = options.dup
    if form.object
      options[:casein_label] ||= form.object.class.human_attribute_name method
      options[:selected] ||= form.object.send(method)
    end
    label_method = options[:label_method] || :name
    casein_collection_select(form, form.object, form.object.model_name.singular, method, collection, :id, label_method, options)
  end
  
  def casein_check_box_i18n(form, method, options={}) 
    options = options.dup
    if form.object
      options[:casein_label] ||= form.object.class.human_attribute_name method
      options[:checked] ||= form.object.send(method)
    end
    casein_check_box(form, form.object, method, options)
  end
end
