class MainController < ApplicationController
  def show
    @root_entity = (Entity[params[:id].to_i] if params[:id]) || (Entity[params[:name]] if params[:name]) || Entity.menu_entities.try(:first)
    
    flash[:warning] = 'Entities not found' unless @root_entity
    
    if @root_entity
      @entities = @root_entity.self_and_descendants
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
    id = params[:id].to_i
    Entity[id].do_event :at_click
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
