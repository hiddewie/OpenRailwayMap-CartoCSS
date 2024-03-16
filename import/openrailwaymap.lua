function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local railway_line = osm2pgsql.define_table({
  name = 'railway_line',
  ids = { type = 'way', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'linestring' },
    { column = 'railway', type = 'text' },
    { column = 'feature', type = 'text' },
    { column = 'service', type = 'text' },
    { column = 'usage', type = 'text' },
    { column = 'highspeed', type = 'text' },
    { column = 'layer', type = 'text' },
    { column = 'ref', type = 'text' },
    { column = 'track_ref', type = 'text' },
    { column = 'name', type = 'text' },
    { column = 'public_transport', type = 'text' },
    { column = 'construction', type = 'text' },
    { column = 'tunnel', type = 'text' },
    { column = 'tunnel_name', type = 'text' },
    { column = 'bridge', type = 'text' },
    { column = 'bridge_name', type = 'text' },
    { column = 'maxspeed', type = 'text' },
    { column = 'maxspeed_forward', type = 'text' },
    { column = 'maxspeed_backward', type = 'text' },
    { column = 'preferred_direction', type = 'text' },
    { column = 'electrified', type = 'text' },
    { column = 'deelectrified', type = 'text' },
    { column = 'frequency', type = 'text' },
    { column = 'voltage', type = 'text' },
    { column = 'gauge', type = 'text' },
    { column = 'construction_railway', type = 'text' },
    { column = 'construction_electrified', type = 'text' },
    { column = 'construction_frequency', type = 'text' },
    { column = 'construction_voltage', type = 'text' },
    { column = 'construction_gauge', type = 'text' },
    { column = 'proposed_railway', type = 'text' },
    { column = 'proposed_electrified', type = 'text' },
    { column = 'proposed_frequency', type = 'text' },
    { column = 'proposed_voltage', type = 'text' },
    { column = 'disused_railway', type = 'text' },
    { column = 'abandoned_railway', type = 'text' },
    { column = 'abandoned_name', type = 'text' },
    { column = 'abandoned_electrified', type = 'text' },
    { column = 'razed_railway', type = 'text' },
    { column = 'razed_name', type = 'text' },
    { column = 'preserved_railway', type = 'text' },
    { column = 'train_protection', type = 'text' },
    { column = 'train_protection_rank', type = 'smallint' },
  },
})

local pois = osm2pgsql.define_table({
  name = 'pois',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'railway', type = 'text' },
    { column = 'man_made', type = 'text' },
  },
})

local stations = osm2pgsql.define_table({
  name = 'stations',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'railway', type = 'text' },
    { column = 'name', type = 'text' },
    { column = 'station', type = 'text' },
    { column = 'label', type = 'text' },
  },
})

local stop_positions = osm2pgsql.define_table({
  name = 'stop_positions',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'name', type = 'text' },
  },
})

local platforms = osm2pgsql.define_table({
  name = 'platforms',
  ids = { type = 'any', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'geometry' },
    { column = 'name', type = 'text' },
  },
})

local signals = osm2pgsql.define_table({
  name = 'signals',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'railway', type = 'text' },
    { column = 'ref', type = 'text' },
    { column = 'tags', type = 'hstore' },
  },
})

local signal_boxes = osm2pgsql.define_table({
  name = 'signal_boxes',
  ids = { type = 'any', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'geometry' },
    { column = 'way_area', type = 'real' },
    { column = 'ref', type = 'text' },
    { column = 'name', type = 'text' },
  },
})

local turntables = osm2pgsql.define_table({
  name = 'turntables',
  ids = { type = 'way', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'polygon' },
  },
})

local railway_positions = osm2pgsql.define_table({
  name = 'railway_positions',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'railway', type = 'text' },
    { column = 'railway_position', type = 'text' },
    { column = 'railway_position_detail', type = 'text' },
  },
})

local railway_switches = osm2pgsql.define_table({
  name = 'railway_switches',
  ids = { type = 'node', id_column = 'osm_id' },
  columns = {
    { column = 'way', type = 'point' },
    { column = 'railway', type = 'text' },
    { column = 'ref', type = 'text' },
    { column = 'railway_local_operated', type = 'text' },
  },
})

local routes = osm2pgsql.define_table({
  name = 'routes',
  ids = { type = 'relation', id_column = 'osm_id' },
  columns = {
    { column = 'platform_ref_ids', sql_type = 'int8[]' },
    { column = 'stop_ref_ids', sql_type = 'int8[]' },
  },
  indexes = {
    { column = 'platform_ref_ids', method = 'gin' },
    { column = 'stop_ref_ids', method = 'gin' },
  },
})

-- Set a value to 'no' if it is null or 0.
function railway_null_or_zero_to_no(value)
  if value == '0' or (not value) then
    return 'no'
  else
    return value
  end
end

-- Get rank by train protection a track is equipped with
-- Other code expects 1 for no protection, 0 for default/unknown
function train_protection(tags)
  if railway_null_or_zero_to_no(tags['railway:ptc']) ~= 'no' then return 'ptc', 13 end
  if railway_null_or_zero_to_no(tags['railway:etcs']) ~= 'no' then return 'etcs', 12 end
  if railway_null_or_zero_to_no(tags['construction:railway:etcs']) ~= 'no' then return 'construction_etcs', 11 end
  if tags['railway:asfa'] == 'yes' then return 'asfa', 10 end
  if tags['railway:scmt'] == 'yes' then return 'scmt', 9 end
  if railway_null_or_zero_to_no(tags['railway:tvm']) ~= 'no' then return 'tvm', 8 end
  if tags['railway:kvb'] == 'yes' then return 'kvb', 7 end
  if tags['railway:atc'] == 'yes' then return 'atc', 6 end
  if (tags['railway:atb'] or tags['railway:atb-eg'] or tags['railway:atb-ng'] or tags['railway:atb-vv']) == 'yes' then return 'atb', 5 end
  if tags['railway:zsi127'] == 'yes' then return 'zsi127', 4 end
  if tags['railway:lzb'] == 'yes' then return 'lzb', 3 end
  if tags['railway:pzb'] == 'yes' then return 'pzb', 2 end

  if (tags['railway:pzb'] == 'no' and tags['railway:lzb'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:atb'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:atc'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:scmt'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:asfa'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:kvb'] == 'no' and tags['railway:tvm'] == 'no' and tags['railway:etcs'] == 'no')
    or (tags['railway:zsi127'] == 'no') then
    return 'other', 1
  end

  return nil, 0
end

-- TODO clean up unneeded tags

local railway_station_values = osm2pgsql.make_check_values_func({'station', 'halt', 'tram_stop', 'service_station', 'yard', 'junction', 'spur_junction', 'crossover', 'site', 'tram_stop'})
local railway_poi_values = osm2pgsql.make_check_values_func({'crossing', 'level_crossing', 'phone', 'tram_stop', 'border', 'owner_change', 'radio'})
-- TODO, include derail?
local railway_signal_values = osm2pgsql.make_check_values_func({'signal', 'buffer_stop'})
local railway_position_values = osm2pgsql.make_check_values_func({'milestone', 'level_crossing', 'crossing'})
local railway_switch_values = osm2pgsql.make_check_values_func({'switch', 'railway_crossing'})
function osm2pgsql.process_node(object)
  local tags = object.tags

  if tags.railway == 'signal_box' then
    signal_boxes:insert({
      way = object:as_point(),
      way_area = 0,
      ref = tags['railway:ref'],
      name = tags.name,
    })
  end

  if railway_station_values(tags.railway) then
    stations:insert({
      way = object:as_point(),
      railway = tags.railway,
      name = tags.short_name or tags.name,
      station = tags.station,
      label = tags['railway:ref'],
    })
  end

  if railway_poi_values(tags.railway) then
    pois:insert({
      way = object:as_point(),
      railway = tags.railway,
      man_made = tags.man_made,
    })
  end

  if tags.public_transport == 'stop_position' then
    stop_positions:insert({
      way = object:as_point(),
      railway = tags.railway,
      name = tags.name,
    })
  end

  if tags.public_transport == 'platform' or tags.railway == 'platform' then
    platforms:insert({
      way = object:as_point(),
      name = tags.name,
    })
  end

  if railway_signal_values(tags.railway) then
    signals:insert({
      way = object:as_point(),
      railway = tags.railway,
      ref = tags.ref,
      tags = tags,
    })
  end

  if railway_position_values(tags.railway) and (tags['railway:position'] or tags['railway:position:detail']) then
    railway_positions:insert({
      way = object:as_point(),
      railway = tags.railway,
      railway_position = tags['railway:position'],
      railway_position_detail = tags['railway:position:detail'],
    })
  end

  if railway_switch_values(tags.railway) and tags.ref then
    railway_switches:insert({
      way = object:as_point(),
      railway = tags.railway,
      ref = tags.ref,
      railway_local_operated = tags['railway:local_operated'],
    })
  end
end

local railway_values = osm2pgsql.make_check_values_func({'rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'construction', 'preserved', 'monorail', 'miniature'})
local railway_turntable_values = osm2pgsql.make_check_values_func({'turntable', 'traverser'})
function osm2pgsql.process_way(object)
  local tags = object.tags

  if railway_values(tags.railway) then
    railway_train_protection, railway_train_protection_rank = train_protection(tags)

    railway_line:insert({
      way = object:as_linestring(),
      railway = tags['railway'],
      service = tags['service'],
      usage = tags['usage'],
      highspeed = tags['highspeed'],
      layer = tags['layer'],
      ref = tags['ref'],
      track_ref = tags['railway:track_ref'],
      name = tags['name'],
      public_transport = tags['public_transport'],
      construction = tags['construction'],
      tunnel = tags['tunnel'],
      tunnel_name = tags['tunnel_name'],
      bridge = tags['bridge'],
      bridge_name = tags['bridge'],
      maxspeed = tags['maxspeed'],
      maxspeed_forward = tags['maxspeed:forward'],
      maxspeed_backward = tags['maxspeed:backward'],
      preferred_direction = tags['railway:preferred_direction'],
      electrified = tags['electrified'],
      deelectrified = tags['deelectrified'],
      frequency = tags['frequency'],
      voltage = tags['voltage'],
      gauge = tags['gauge'],
      construction_railway = tags['construction:railway'],
      construction_electrified = tags['construction:electrified'],
      construction_frequency = tags['construction:frequency'],
      construction_voltage = tags['construction:voltage'],
      construction_gauge = tags['construction:gauge'],
      proposed_railway = tags['proposed:railway'],
      proposed_electrified = tags['proposed:electrified'],
      proposed_frequency = tags['proposed:frequency'],
      proposed_voltage = tags['proposed:voltage'],
      disused_railway = tags['disused:railway'],
      abandoned_railway = tags['abandoned:railway'],
      abandoned_name = tags['abandoned:name'],
      abandoned_electrified = tags['abandoned:electrified'],
      razed_railway = tags['razed:railway'],
      razed_name = tags['razed:name'],
      preserved_railway = tags['preserved:railway'],
      train_protection = railway_train_protection,
      train_protection_rank = railway_train_protection_rank,
    })
  end

  if tags.public_transport == 'platform' or tags.railway == 'platform' then
    platforms:insert({
      way = object:as_linestring(),
      name = tags.name,
    })
  end

  if railway_turntable_values(tags.railway) then
    turntables:insert({
      way = object:as_polygon(),
    })
  end

  if tags.railway == 'signal_box' then
    local polygon = object:as_polygon():transform(3857)
    signal_boxes:insert({
      way = polygon,
      way_area = polygon:area(),
      ref = tags['railway:ref'],
      name = tags.name,
    })
  end
end

local route_values = osm2pgsql.make_check_values_func({'train', 'subway', 'tram', 'light_rail'})
local route_stop_relation_roles = osm2pgsql.make_check_values_func({'stop', 'station', 'stop_exit_only', 'stop_entry_only', 'forward_stop', 'backward_stop', 'forward:stop', 'backward:stop', 'stop_position', 'halt'})
local route_platform_relation_roles = osm2pgsql.make_check_values_func({'platform', 'platform_exit_only', 'platform_entry_only', 'forward:platform', 'backward:platform'})
function osm2pgsql.process_relation(object)
  local tags = object.tags

  if tags.type == 'route' and route_values(tags.route) then
    local stop_members = {}
    local platform_members = {}
    for _, member in ipairs(object.members) do
      if route_stop_relation_roles(member.role) then
        table.insert(stop_members, member.ref)
      end

      if route_platform_relation_roles(member.role) then
        table.insert(platform_members, member.ref)
      end
    end

    if (#stop_members > 0) or (#platform_members > 0) then
      routes:insert({
        stop_ref_ids = '{' .. table.concat(stop_members, ',') .. '}',
        platform_ref_ids = '{' .. table.concat(platform_members, ',') .. '}',
      })
    end
  end
end