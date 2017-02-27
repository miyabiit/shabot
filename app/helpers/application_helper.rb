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

  # NOTE casein_show_row_icon ではtitle属性の変更ができないので、アイコンリンク専用のヘルパーとして用意
  def table_row_icon_link_to(icon_name, path, title: nil, link_options: nil)
    link_to path, link_options do
      concat content_tag(:div, class: 'iconRow') {
        "<span class='glyphicon glyphicon-#{icon_name}' title='#{title}'></span>".html_safe
      }.html_safe
    end
  end

  def table_row_add_icon_link_to(path, options={})
    table_row_icon_link_to('plus-sign', path, title: '新規作成', link_options: options)
  end

  def table_row_trash_icon_link_to(path, options={})
    table_row_icon_link_to('trash', path, title: '削除', link_options: options)
  end

  def table_row_retweet_icon_link_to(path, options={})
    table_row_icon_link_to('retweet', path, title: '参照作成', link_options: options)
  end

  def table_row_pdf_icon_link_to(path, options={})
    table_row_icon_link_to('save-file', path, title: 'PDF', link_options: options)
  end

  def query_params
    {q: params[:q], c: params[:c], d: params[:d], page: params[:page]}
  end
end
