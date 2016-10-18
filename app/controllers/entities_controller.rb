class EntitiesController < ApplicationController

  before_action :set_entity, only: [:show, :edit, :update, :destroy]
  before_action :admin_user!
  
  def classes
    @root_class = Entity
    @entities = Entity.all.to_a
  end
  
  # GET /entities
  def index
    @filter = params.permit(:driver, :type)
    @entities = Entity.eager_load(:jobs).all.where(@filter).order(:lft, 'delayed_jobs.run_at')
  end

  # GET /entities/1
  def show

  end

  # GET /entities/new
  def new
    source_id = params[:format]
    if source_id
      source_entity = Entity.find source_id
      source_attribs = source_entity.attributes.reject{|k,v| %w(lft rgt depth).include? k.to_s }
    else
      source_attribs = params.permit(:driver, :address) if params
    end  
    @entity = Entity.new(source_attribs)
    
    set_form_variables
  end

  # GET /entities/insert/1
  def insert
    @entity = Entity.new
    @entity.parent_id = params[:parent].to_f
    set_form_variables
    render :new
  end

  # GET /entities/1/edit
  def edit
    set_form_variables
  end

  # POST /entities
  # POST /entities.json
  def create
#    byebug
    params = entity_params
    @entity = Entity.new(params)
    @entity.behavior_script = params[:behavior_script]
    if @entity.save
      redirect_to entities_path, notice: 'Entity was successfully created.'
    else
      edit
      render :new
    end
  end

  # PATCH/PUT /entities/1
  # PATCH/PUT /entities/1.json
  def update
    ep = entity_params
    @entity = @entity.becomes(ep[:type].constantize) if @entity.type != ep[:type]
    
 #   flash[:info] = @entity.class.name
    
    if @entity.update(ep)
      redirect_to entities_path, notice: 'Entity was successfully updated.'
    else
      edit
      render :edit
    end
  end

  # DELETE /entities/1
  # DELETE /entities/1.json
  def destroy
    if !@entity.destroy
      er, notice = @entity.errors.full_messages.join, nil
    else
      er, notice = nil, 'Entity was successfully destroyed.'
    end
    redirect_to :back, notice: notice, alert: er
  end

  private
  
  def set_form_variables
    @entity_types = Entity.entity_types
    @drivers_names = Entity.drivers_names
    @parents = allowed_parents
  end
  
  def allowed_parents
    sd = @entity.self_and_descendants
    Entity.all.reject{|e| sd.include? e }
  end 

  # Use callbacks to share common setup or constraints between actions.
  def set_entity
    @entity = Entity.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def entity_params
     p = params.require(:entity).permit(:name, :type, :caption, :address, :location_x, :location_y, :value, :parent_id, :driver, :power, :behavior_script)
     p[:name].strip!
     return p
#    et = Entity.entity_types.map{|e| e.downcase } << 'entity'
#    params.require(params.find{|key, value| et.include? key}[0]).permit(:name, :type, :caption, :address, :left, :top, :value, :parent_id)
  end
end
