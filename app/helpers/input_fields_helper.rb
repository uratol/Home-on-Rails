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
    if default.respond_to? :in_time_zone
      def_seconds = default.in_time_zone.seconds_since_midnight.to_i
    else
      def_seconds = default.to_i
    end

    def_days = def_seconds / (24 * 3600)
    def_seconds -= def_days * (24 * 3600)
    def_hours = def_seconds / 3600
    def_seconds -= def_hours * 3600
    def_minutes = def_seconds / 60
    def_seconds -= def_minutes * 60

    only = options[:only]
    only = [*only].map(&:to_sym) if only
    options.except!(:only)

    inputs = {
      days:
          {

              caption: t(:days),
              select: (0..366).to_a,
              default: def_days
          },
      hours:
          {
              caption: t(:hours),
              select: (0..23).to_a,
              default: def_hours
          },
      minutes:
          {
              caption: t(:minutes),
              select: (0..59).to_a,
              default: def_minutes
          },
      seconds:
          {
              caption: t(:seconds),
              select: (0..59).to_a,
              default: def_seconds
          }
    }

    inputs.reject!{|key, value| (not only.include?(key.to_sym))} if only

    inputs = inputs.inject('') do |result, (key, hash)|
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
