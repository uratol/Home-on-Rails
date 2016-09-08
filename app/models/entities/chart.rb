class Chart < Widget

  register_attributes width: 900,  height: 850, period_default: 1.day

  @chart_type = nil
  def devices
    Device.all
  end
  
  def chart_type
    return @chart_type if @chart_type
    if devs.detect{|d| !d.binary?}
      @chart_type = :LineChart
    else
      @chart_type = :Timeline  
    end
  end

  def data_js dt_from = period_default.ago, dt_to = Time.now
    if chart_type == :Timeline 
      timeline_data_js
    else
      line_data_js
    end     
  end

  def devs 
    @devs ||= [*devices]
  end

  private
  
  
  def line_data_js dt_from = period_default.ago, dt_to = Time.now
    round_seconds = 5 * 60
    datetime_int_field = ActiveRecord::Base.connection.adapter_name=='PostgreSQL' ? "EXTRACT(EPOCH FROM created_at)::int" : "cast(strftime('%s',created_at) as integer)"
    datetime_group_field = "#{ datetime_int_field } - (#{ datetime_int_field } % #{ round_seconds })"
    rounded_indications_query = "
    SELECT #{ datetime_group_field } as dt, entity_id, value
    FROM indications
    WHERE entity_id in (?) AND created_at BETWEEN ? AND ?
LIMIT 10000 
    "
    
    sql_query = "
      SELECT 
        #{ devs.inject('dt'){|command, device| "#{ command } , AVG(case when entity_id=#{ device.id } then value end) as id#{ device.id }"} }
      FROM (#{ rounded_indications_query }) as a
      GROUP BY dt
      ORDER BY dt
      "
    
    puts sql_query  
    
    result = Entity.execute_sql(sql_query, devs.to_a, dt_from, dt_to)
    #byebug
    result = result.map do |row|
      row_s = row.inject("") do |rs, (k,v)|
        rs + if k == "dt"
          "new Date(#{ v.to_i * 1000 })"
        elsif k.start_with?('id')
          ',' + (v || 'null').to_s
        else 
          ""
        end
      end
      '[' + row_s  + ']'
    end
      
    '[' + result.join(',') + ']'
  end

  def timeline_data_js dt_from = period_default.ago, dt_to = Time.now
    result, previous = [], {}

    devs_hash = devs.inject({}){|s,e| s.merge!({e.id => e.caption}) }
    
#    return Indication.select(:entity_id,:dt,:value).where(entity: devs).where(created_at: dt_from..dt_to).order(:entity_id, :dt)

    indications_array = Indication.select(:entity_id,:dt,:value).where(entity: devs, created_at: dt_from..dt_to).order(:entity_id, :dt)
    
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
  end 
end








