module ApplicationHelper
  def full_title(page_title=nil)
    base_title = Home.title
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  
  def types_options( start_class = Entity, start_level = 0)
    result = [ [start_class.name , start_class.name, {'data-depth' => start_level, 'data-image' => start_class.img}] ]
    
    start_class.subclasses.each do |sc|
        result += types_options(sc, start_level+1)
    end
    result
  end

  def drivers_options
    Entity.drivers.map do |d|
      [d.driver_name.capitalize, d.driver_name, { 'data-description' => d.try(:description) }]
    end
  end

=begin
  def parents_options(parents, entity)
    nested_set_options(@parents, @entity) { |i| "#{'&nbsp;'*2 * i.depth}#{ i.name} : #{ i.type }".html_safe }.map do |two|
      two << {'data-image' => Entity[two.second].img }
    end
  end
=end

  def parents_options(class_or_item, mover = nil)
    if class_or_item.is_a? Array
      items = class_or_item.reject { |e| !e.root? }
    else
      class_or_item = class_or_item.roots if class_or_item.respond_to?(:scope)
      items = Array(class_or_item)
    end
    result = []
    items.each do |root|
      result += root.class.associate_parents(root.self_and_descendants).map do |i|
        if mover.nil? || mover.new_record? || mover.move_possible?(i)
          (img = i.img) rescue Exception
          depth = i.depth
          [i.name, i.primary_id, {'data-image' => (img if img.to_s != ''), 'data-depth' => (depth if depth > 0) , 'data-description' => i.type }]
        end
      end.compact
    end
    result
  end


  def isadmin?
    current_user.try :isadmin
  end

  private
  
  
end
