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

  # NOTE: casein_sort_linkではajax更新時にリンクアドレスが変わってしまうので、明示的にパスを渡して回避する
  def sort_link(title, column, path)
    icon_to_show_html = "<div class='table-header-icon'>&nbsp;</div>".html_safe
    if params[:c].to_s == column.to_s
      icon_to_show = params[:d] == 'down' ? 'chevron-up' : 'chevron-down'
      icon_to_show_html = "<div class='table-header-icon glyphicon glyphicon-#{icon_to_show}'></div>".html_safe
    end
    sort_dir = params[:d] == 'down' ? 'up' : 'down'
    link_to(title, path + (path.include?('?') ? '&' : '?') + {:c => column, :d => sort_dir}.to_query) + icon_to_show_html
  end
end
