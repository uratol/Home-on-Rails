class EntitiesController < ApplicationController

  before_action :set_entity, only: [:show, :edit, :update, :destroy, :export]
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
      @source_entity = Entity.find source_id
      source_attribs = @source_entity.attributes_for_copy
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
    params = entity_params
    @entity = Entity.new(params)
    @entity.behavior_script = params[:behavior_script]

    @source_entity = Entity.find(self.params[:source_id]) if self.params[:source_id]

    #saved = self.params['create_descendants'] == 1 && @source_entity ? @entity.save_and_create_descendants(@source_entity) : @entity.save

    if @entity.save_and_copy_descendants(self.params['create_descendants'].to_s == '1' ? @source_entity : nil)
      redirect_to(entities_path, notice: 'Entity was successfully created.')
    else
      set_form_variables
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
    if @entity.destroy_with_descendants
      er, notice = nil, 'Entity was successfully destroyed.'
    else
      er, notice = @entity.errors.full_messages.join, nil
    end
    redirect_to :back, notice: notice, alert: er
  end

  # GET /entities/export/1
  def export
    send_data @entity.export_hash.to_json, filename: "#{@entity.name}.json"
  end

  def import
    @entity = params[:id] == 'root' ? nil : Entity.find(params[:id])
    @parents = Entity.all
  end

  def do_import
    @parent = params[:parent].blank? ? nil : Entity.find(params[:parent])
    imported_entities = 0
    imported_images = 0

    if params[:files] && params[:files].any?
      entities = params[:files].map{|f| JSON.parse(f.read) }
    else
      redirect_to :back, alert: 'Files not choosen'
      return
    end

    import_result = {}
    notice = nil
    errors = nil
    ActiveRecord::Base.transaction do
      name_mask = params[:name_mask]
      name_mask = '*' if name_mask.nil? || name_mask.blank?
      caption_mask = params[:caption_mask]
      caption_mask = '*' if caption_mask.nil? || caption_mask.blank?
      import_result = import_from_array(entities, @parent, name_mask, caption_mask, params[:import_images],import_result)
      if import_result[:errors]
        errors = import_result[:errors].join(".\n")
        raise ActiveRecord::Rollback
      else
        notice = "#{ import_result[:entities] || 0} entities was successfully imported.\n
        #{ import_result[:images] || 0 } images was successfully imported\n"
      end
    end

    redirect_to errors ? :back : entities_path, notice: notice, alert: errors

  end

  private
  
  def set_form_variables
    @source_entity ||= nil
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

  PERMITTED_ATTRIBS = %w(name type caption address location_x location_y value parent_id driver power behavior_script disabled hidden width height)

  # Never trust parameters from the scary internet, only allow the white list through.
  def entity_params
     p = params.require(:entity).permit(*PERMITTED_ATTRIBS)
     p[:name].strip!
     p
  end

  def import_from_array(entities, parent, name_mask, caption_mask, import_images, result)
    entities.each do |hash|
      hash['parent_id'] = parent.try :id
      hash['name'] = name_mask.gsub('*', hash['name'])
      hash['caption'] = caption_mask.gsub('*', hash['caption'])
      e = Entity.new(hash.slice(* PERMITTED_ATTRIBS))
      e.behavior_script = hash['behavior_script']
      if e.save
        result[:entities] = (result[:entities] || 0) + 1
      else
        result[:errors] = (result[:errors] || []) + ["Error: #{ e.errors.to_a.join(';') } (#{ hash.except('children','images') })"]
      end
      result.merge!(import_from_array(hash['children'], e, name_mask, caption_mask, import_images, result)) if hash['children']
      if hash['images'] && import_images && result[:errors].nil?
        hash['images'].each do |img|
          img.each_pair do |file_name, base64|
            File.open(Rails.root.join('app','assets','images',EntityVisualization::ICON_RELATIVE_LOCATION, file_name), 'wb') do |file|
              file.write(Base64.decode64(base64))
            end
            result[:images] = (result[:images] || 0) + 1
          end
        end
      end
    end
    result
  end


end
