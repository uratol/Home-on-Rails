module InputFieldsHelper

  def checkbox_field_tag(name, default, options)
    check_box_tag(name, nil, default, options)
  end

  def select_field_tag(name, default, options)
    select_tag(name, options_for_select(options[:select], default), options)
  end

  def range_field_tag(name, default, options)
    content_tag(:div,
                content_tag(:div, default, class: :range_indicator)
                                            .concat(super(name, default, options.merge(class: :range))),
                class: :range_container
    )
  end

  def duration_field_tag(name, default, options)
    default = default.in_time_zone
    inputs = {
      days:
          {

              caption: t(:days),
              select: (0..31).to_a
          },
      hours:
          {
              caption: t(:hours),
              select: (0..23).to_a,
              default: default.hour
          },
      minutes:
          {
              caption: t(:minutes),
              select: (0..59).to_a,
              default: default.min
          }
    }.inject('') do |result, (key, hash)|
      result.concat( content_tag(:div, (
          content_tag(:div, hash[:caption],class: "duration_label duration_#{ key }")
            .concat select_tag("#{ name }[#{ key }]", options_for_select(hash[:select], hash[:default]), options)
      ), class: :duration_element)
      )
    end

    content_tag(:div, inputs.html_safe, class: :duration_container)

=begin
    content_tag(:div,
                content_tag(:span, "D")
                .concat(select_tag(name + '[days]', options_for_select((0..31).to_a), options))
                .concat(content_tag(:span, "H"))
                .concat(select_tag(name + '[hours]', options_for_select((0..23).to_a), options))
                .concat(content_tag(:span, "M"))
                .concat(select_tag(name + '[minutes]', options_for_select((0..59).to_a), options)),
     class: :duration)
=end
  end

end
