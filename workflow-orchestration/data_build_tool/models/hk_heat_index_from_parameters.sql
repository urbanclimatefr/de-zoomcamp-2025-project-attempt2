-- models/hk_heat_index_from_parameters.sql

{{
  config(
    materialized='table',
    unique_key='place_time_key'
  )
}}

-- First, pivot the parameter data into a structured format
with parameter_pivot as (
  select
    place,
    record_time,
    max(case when parameter = 'temperature' then value end) as temperature_c,
    max(case when parameter = 'humidity' then value end) as humidity_percent
  from {{ ref('raw_weather_parameters') }}
  where parameter in ('temperature', 'humidity')
  group by place, record_time
),

-- Join with nearby humidity data for locations missing humidity
with_humidity as (
  select
    p.place,
    p.record_time,
    p.temperature_c,
    coalesce(p.humidity_percent, 
             h.humidity_percent) as humidity_percent
  from parameter_pivot p
  left join parameter_pivot h 
    on h.parameter = 'humidity'
    and h.record_time = p.record_time
    -- Join with Hong Kong Observatory humidity if local humidity missing
    and h.place = 'Hong Kong Observatory'
  where p.parameter = 'temperature'
),

-- Calculate thermal metrics
thermal_calculations as (
  select
    place,
    record_time,
    temperature_c as dry_bulb_temp,
    humidity_percent,
    
    -- Calculate natural wet bulb temperature using Stull's method
    (temperature_c * atan(0.151977 * sqrt(humidity_percent + 8.313659))) 
    + atan(temperature_c + humidity_percent) 
    - atan(humidity_percent - 1.676331) 
    + (0.00391838 * power(humidity_percent, 1.5) * atan(0.023101 * humidity_percent)) 
    - 4.686035 as natural_wet_bulb_temp,
    
    -- Estimate globe temperature (Tg) as temperature + 3°C in daylight hours
    case 
      when extract(hour from record_time) between 6 and 18 then temperature_c + 3
      else temperature_c + 1
    end as globe_temp_estimate
  from with_humidity
),

-- Calculate Hong Kong Heat Index
final_calculations as (
  select
    place,
    record_time,
    dry_bulb_temp,
    humidity_percent,
    natural_wet_bulb_temp,
    globe_temp_estimate,
    
    -- Hong Kong Heat Index calculation
    0.80 * natural_wet_bulb_temp + 
    0.05 * globe_temp_estimate + 
    0.15 * dry_bulb_temp as hong_kong_heat_index,
    
    -- Create unique key
    md5(place || record_time::text) as place_time_key
  from thermal_calculations
)

select
  place,
  record_time,
  dry_bulb_temp,
  humidity_percent,
  natural_wet_bulb_temp,
  globe_temp_estimate,
  hong_kong_heat_index,
  
  -- Interpretation categories
  case
    when hong_kong_heat_index < 25 then 'Cool'
    when hong_kong_heat_index between 25 and 29 then 'Warm'
    when hong_kong_heat_index between 30 and 34 then 'Hot'
    when hong_kong_heat_index > 34 then 'Very Hot'
  end as hk_heat_index_category,
  
  -- Heat stress warning
  case
    when hong_kong_heat_index > 30 and humidity_percent > 70 then 'High Risk'
    when hong_kong_heat_index > 28 or humidity_percent > 80 then 'Moderate Risk'
    else 'Low Risk'
  end as heat_stress_warning,
  
  place_time_key
  
from final_calculations