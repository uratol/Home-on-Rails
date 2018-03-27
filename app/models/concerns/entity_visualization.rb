module EntityVisualization
  extend ActiveSupport::Concern
  
  included do
    register_attributes(:caption_class)

    attr_accessor(:redirect_target)
    attr_accessor(:input_items)
  end

  def human_value
    ("%g" % ("%.2f" % value) if value).to_s
  end

  def image
    icon_relative_location = "entities"
    file_exts = %w[png gif jpg jpeg]
    file_bases = [(image_name||name).to_s] + self.class.ancestors_and_self(Entity.superclass).map{|c| c.name.downcase} 
    file_values =  []
    file_values << '.'+human_value if value
    file_values << ''
    files = Dir.entries Rails.root.join('app','assets','images',icon_relative_location)
    files += Dir.entries Home::Engine.root.join('app','assets','images',icon_relative_location)
    
    for file_base in file_bases
      for file_value in file_values
        for file_ext in file_exts
          f = "#{ file_base+file_value }.#{ file_ext }"
          return File.join(icon_relative_location,f) if files.include? f 
        end
      end
    end
    nil
  rescue Exception
    nil
  end

  # Redirects browser to object or url
  # @param target [Entity, String]
  # @example Redirect to object
  #   at_click do
  #     redirect_to floor1
  #   end
  # @example Redirect to url
  #   at_click do
  #     redirect_to 'http://google.com'
  #   end
  def redirect_to(target)
    self.redirect_target = target
  end

  # @!visibility private
  def img
    ActionController::Base.helpers.asset_path(image)
  end

  # Provide access to browser request parameters, including {#input} users data
  # @return [Hash]
  def params
    controller.try(:params)
  end

  # Provide access to current Ruby On Rails controller
  # @return [ActionController::Base]
  def controller
    Entity.controller
  end

  # Allows you to request additional information from the user
  # by displaying a dialog box
  # @param [Array<Hash>] input_items contains array of [Hash] represented visual controls in dialog. Each [Hash] contains the keys:
  # @option input_items [String] :caption Caption of control, required. For :range control caption can include wildcard %value, which will be replaced by current value
  # @option input_items [:text, :number, :range, :checkbox, :select, :time, :date, :datetime, :color] :type Type of control, default :text
  # @option input_items [String, Number] :default Default value of control
  # Depending on :type, other properties can also be specified, google: html input
  #
  # @return [true, false] Returns true at second method call, wherein {#params} contains user input data
  # @example
  #   at_click do
  #     if input(
  #         {caption: num = "номер (%value)" , type: :range, default: data.num, min: 1, max: 15},
  #         {caption: "цвет", type: :color, default: data.color},
  #         {caption: "email", type: :email, default: data.text, size: 25, style: "background-color: #{ data.color }"},
  #         {caption: "список", type: :select, select:  ['one','two','three'], default: 'two'},
  #         {caption: "птичка", type: :checkbox, default: data.checked}
  #     )
  #       data.text = params["email"]
  #       data.color = params["цвет"]
  #       data.num = params[num]
  #       data.checked = params["птичка"]
  #     end
  #   end
  def input(*input_items)
    input_items.flatten!
    is_first_call = !(params[input_items.first[:name]] || params[input_items.first[:caption]])
    @input_items = input_items if is_first_call
    !is_first_call
  end

  module ClassMethods
    # class methods
  end  
end