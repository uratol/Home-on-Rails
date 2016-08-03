class Chart < Widget

  register_attributes width: 900,  height: 850, devices: nil, period_default: 1.month

  def timeline_data_js dt_from = period_default.ago, dt_to = Time.now
    
    self.devices ||= Device.all 

    result, previous = [], {}

    devs_hash = devices.inject({}){|s,e| s.merge!({e.id => e.caption}) }
    
#    return Indication.select(:entity_id,:dt,:value).where(entity: devices).where(created_at: dt_from..dt_to).order(:entity_id, :dt)

    indications_array = Indication.select(:entity_id,:dt,:value).where(entity: devices, created_at: dt_from..dt_to).order(:entity_id, :dt)
    
    indications_array.each do |r|

      p = previous[r.entity_id] 
      unless p 
        p = Indication.indication_at(r.entity_id,dt_from)
        p.dt = dt_from if p
      end
      
      if p.nil? || p.value != r.value
        
        
        if r.value==0 && p
          result += [[ devs_hash[r.entity_id], "new Date(#{ p.dt.to_f*1000 })", "new Date(#{ r.dt.to_f*1000 })"]]
#          previous[r.entity_id] = nil
        else
          if r.value!=0 && !indications_array.detect{|i| i.entity_id==r.entity_id && i.dt>r.dt}
            result += [[ devs_hash[r.entity_id], "new Date(#{ r.dt.to_f*1000 })", "new Date(#{ dt_to.to_f*1000 })"]]
            #result += [[ devs_hash[r.entity_id], dt1, dt2]]
          end
        end
        previous[r.entity_id] = r
      end  

    end
    result.to_s.gsub('"new Date(','new Date(').gsub(')"',')').html_safe
#    result.to_s.gsub('"new Date(','new Date(').gsub(')"',')').html_safe
  end 
end








