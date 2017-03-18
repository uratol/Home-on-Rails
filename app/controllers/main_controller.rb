class MainController < ApplicationController
  def show
    @root_entity = (Entity[params[:id].to_i] if params[:id]) || (Entity[params[:name]] if params[:name]) || Entity.menu_entities.try(:first)
    
    flash[:warning] = 'Entities not found' unless @root_entity
    
    if @root_entity
      @entities = @root_entity.self_and_descendants.where("disabled = ? or id = ?", false, @root_entity)
    else
      @entities = []  
    end  
    
    respond_to do |format|
      format.html # render default view
      format.json do
        render json: @entities
      end
    end 
    #@entities = @root_entity.get_descendants
    #flash[:info] = Entity.first.ku
  end
  
  def click
    process_event(:at_click)
  end
  
  def touchstart
    process_event(:at_touchstart)
  end
  
  def touchend
    process_event(:at_touchend)
  end
  
  def change
    id = params[:id].to_i
    e = Entity[id]
    e.write_value(params[:value].to_f)
    refresh
  end
  
  def refresh
    id = params[:root].to_i

    entities = if id==0 then Entity.all else Entity[id].self_and_descendants end
    
    respond_to do |format|
      format.json do 
        render json: entities, only:[:id] , methods: [:img, :brightness, :text]
      end
    end
  end
  
  def design_apply
    JSON.parse(params[:data]).each do |p|
      Entity[ p['id'].to_i ].tap do |e|
         e.location_x = p['left'] || p['index']
         e.location_y = p['top']
         e.save!
      end   
    end
    redirect_to :back
  end

  private

  def process_event(event_name)
    e = Entity[params[:id].to_i]
    e.do_event(event_name)
    target = e.redirect_target
    if target
      e.redirect_target = nil
      redirect_to(target.is_a?(Entity) ? "/show/#{ target.name }" : target)
    else
      refresh
    end
  end

end

=begin
//= require jquery
//= require jquery_ujs

//= require jquery-ui
//= require jquery.contextMenu.js

//= require ace/ace
//= require ace/worker-html
//= require ace/mode-ruby



*= require jquery-ui
 *= require jquery.contextMenu.css
 * 
 
=end
