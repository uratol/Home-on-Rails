module ApplicationHelper
  def full_title(page_title=nil)
    base_title = Home.title
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  
  def types_options start_class = Entity, start_level = 0, &block
    result = [ [yield(start_class, start_level), start_class.name] ]
    
    start_class.subclasses.each do |sc|
        result += types_options(sc, start_level+1, &block)
    end
    result    
  end

  def isadmin?
    current_user.try :isadmin
  end

  private
  
  
end
