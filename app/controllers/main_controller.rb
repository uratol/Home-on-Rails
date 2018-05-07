class MainController < ApplicationController
  
  rescue_from Exception, with: :handle_exception

  before_filter :provide_controller_to_model
  skip_before_filter :verify_authenticity_token, only: :refresh

  def show
    @root_entity = root_entity
    
    flash[:warning] = 'Entities not found' unless @root_entity
    
    if @root_entity
      @entities = @root_entity.self_and_descendants.where("hidden = ? or id = ?", false, @root_entity)
    else
      @entities = []  
    end  
    
    respond_to do |format|
      format.html # render default view
      format.json do
        render json: @entities
      end
    end 
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
    # id = params[:root].to_i
    # entities = id==0 ? Entity.all : Entity[id].self_and_descendants
    @root_entity = root_entity

    return unless @root_entity

    entities = @root_entity.self_and_descendants
    
    respond_to do |format|
      format.json do
        render json: entities, only:[:id] , methods: [:img, :brightness, :text, :refresh_script]
      end
    end
  end
  
  def design_apply
    JSON.parse(params[:data]).each do |p|
      e = Entity.find_by_id(p['id'].to_i)
      if e
        i = p['left'] || p['index']
        e.location_x = i if i
        i = p['top']
        e.location_y = i if i
        i = p['width']
        e.width = p['width'] if i
        i = p['height']
        e.height = i if i
        e.save!
      else
        flash[:error] = "Couldn't find Entity with 'id'=#{ p['id'] }"
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

  def root_entity
    (Entity[params[:name]] if params[:name]) || Entity.menu_entities.try(:first)
  end

  def provide_controller_to_model
    Entity.controller = self
  end

  def process_event(event_name)
    e = Entity[params[:id].to_i]
    e.do_event(event_name)
    if e.javascript
      render js: e.javascript
    elsif e.input_items
      @entity = e
      @root_entity = root_entity
      render js: render_to_string('main/input')
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
