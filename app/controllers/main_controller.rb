class MainController < ApplicationController
  
  rescue_from Exception, with: :handle_exception
  
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

    entities = id==0 ? Entity.all : Entity[id].self_and_descendants
    
    respond_to do |format|
      format.json do 
        render json: entities, only:[:id] , methods: [:img, :brightness, :text, :refresh_script]
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
  
  protected
  
  def handle_exception(e)
    
    respond_to do |format|
      format.json do
        error_message = e.message
        error_message += '; ' + e.response.body.to_s if e.respond_to?(:response)
        render(json: {ent: Entity.find_by_id(params[:id]).to_s, message: error_message, stack: e.backtrace.first(3)}, status: 500)
      end

      format.html do
        raise(e)
      end
    end
  end  

  private

  def process_event(event_name)
    e = Entity[params[:id].to_i]
    e.do_event(event_name)
    target = e.redirect_target
    if target
      e.redirect_target = nil
      render :js => "window.location = '#{ target.is_a?(Entity) ? "/show/#{ target.name }" : target }'"
      #redirect_to(target.is_a?(Entity) ? "/show/#{ target.name }" : target)
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
