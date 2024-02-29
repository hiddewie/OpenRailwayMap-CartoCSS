CREATE OR REPLACE VIEW railway_line_low AS
  SELECT
    way,
    railway,
    railway as feature,
    usage,
    highspeed,
    NULL AS service,
    false as tunnel,
    false as bridge,
    CASE
      WHEN railway = 'rail' AND usage = 'main' AND highspeed = 'yes' THEN 2000
      WHEN railway = 'rail' AND usage = 'main' THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' THEN 1000
      ELSE 50
    END AS rank
  FROM
    (SELECT
       way,
       railway,
       usage,
       tags->'highspeed' AS highspeed,
       layer
     FROM openrailwaymap_osm_line
     WHERE railway = 'rail' AND usage IN ('main', 'branch') AND service IS NULL
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_line_med AS
  SELECT
    way,
    railway,
    railway as feature,
    usage,
    highspeed,
    NULL AS service,
    false as tunnel,
    false as bridge,
    CASE
      WHEN railway = 'rail' AND usage = 'main' AND highspeed = 'yes' THEN 2000
      WHEN railway = 'rail' AND usage = 'main' THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' THEN 1000
      ELSE 50
    END AS rank
  FROM
    (SELECT
        way,
        railway,
        usage,
        tags->'highspeed' AS highspeed,
        layer
      FROM openrailwaymap_osm_line
      WHERE railway = 'rail' AND usage IN ('main', 'branch') AND service IS NULL
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_turntables AS
  SELECT
    way,
    railway
  FROM openrailwaymap_osm_polygon
  WHERE railway IN ('turntable', 'traverser');

CREATE OR REPLACE VIEW railway_line_fill AS
  SELECT
    way,
    railway,
    CASE
      WHEN railway = 'proposed' THEN proposed_railway
      WHEN railway = 'construction' THEN construction_railway
      WHEN railway = 'razed' THEN razed_railway
      WHEN railway = 'abandoned' THEN abandoned_railway
      WHEN railway = 'disused' THEN disused_railway
      ELSE railway
    END as feature,
    usage,
    highspeed,
    service,
    (bridge IS NOT NULL AND bridge != 'no') as bridge,
    (tunnel IS NOT NULL AND tunnel != 'no') as tunnel,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
        WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
        WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
        WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
        WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
        WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
        WHEN railway = 'rail' AND usage = 'main' AND service IS NULL AND highspeed = 'yes' THEN 2000
        WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
        WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
        WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
        WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
        WHEN railway IN ('preserved', 'construction') THEN 400
        WHEN railway = 'proposed' THEN 350
        WHEN railway = 'disused' THEN 300
        WHEN railway = 'abandoned' THEN 250
        WHEN railway = 'razed' THEN 200
        ELSE 50
      END AS rank
  FROM
    (SELECT
       way, railway, usage, service, tags->'highspeed' AS highspeed,
       tags->'disused:railway' AS disused_railway, tags->'abandoned:railway' AS abandoned_railway,
       tags->'razed:railway' AS razed_railway, tags->'construction:railway' AS construction_railway,
       tags->'proposed:railway' AS proposed_railway,
       layer,
       bridge,
       tunnel
     FROM openrailwaymap_osm_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'abandoned', 'razed', 'construction', 'proposed')
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_text_stations_med AS
  SELECT
    way, railway, station,
    CASE WHEN railway = 'station' AND station = 'light_rail' THEN 450
         WHEN railway = 'station' AND station = 'subway' THEN 400
         WHEN railway = 'station' THEN 800
         WHEN railway = 'halt' AND station = 'light_rail' THEN 500
         WHEN railway = 'halt' THEN 550
         WHEN railway = 'tram_stop' THEN 300
         WHEN railway = 'service_station' THEN 600
         WHEN railway = 'yard' THEN 700
         WHEN railway = 'junction' THEN 650
         WHEN railway = 'spur_junction' THEN 420
         WHEN railway = 'site' THEN 600
         WHEN railway = 'crossover' THEN 700
         ELSE 50
      END AS rank,
    label
  FROM
    (SELECT
       way,
       railway,
       route_count,
       tags->'station' AS station,
       tags->'railway:ref' AS label
     FROM stations_with_route_counts
     WHERE railway IN ('station', 'halt', 'service_station', 'yard', 'junction', 'spur_junction', 'crossover', 'site')
       AND (name IS NOT NULL OR tags ? 'short_name')
    ) AS r
  ORDER by rank DESC NULLS LAST, route_count DESC NULLS LAST;

CREATE OR REPLACE VIEW railway_text_stations_high AS
  SELECT
    way, railway, station,
    CASE WHEN railway = 'station' AND station = 'light_rail' THEN 450
         WHEN railway = 'station' AND station = 'subway' THEN 400
         WHEN railway = 'station' THEN 800
         WHEN railway = 'halt' AND station = 'light_rail' THEN 500
         WHEN railway = 'halt' THEN 550
         WHEN railway = 'tram_stop' THEN 300
         WHEN railway = 'service_station' THEN 600
         WHEN railway = 'yard' THEN 700
         WHEN railway = 'junction' THEN 650
         WHEN railway = 'spur_junction' THEN 420
         WHEN railway = 'site' THEN 600
         WHEN railway = 'crossover' THEN 700
         ELSE 50
      END AS rank,
    label
  FROM
    (SELECT
       way,
       railway,
       CASE
         WHEN railway = 'tram_stop' OR (tags?'station' AND tags->'station' IN ('subway', 'light_rail', 'miniature')) THEN route_count / 2
         WHEN railway IN ('station', 'service_station', 'yard') AND route_count < 4 THEN 4::int
         WHEN railway IN ('halt', 'junction') AND route_count < 2 THEN 2::int
         ELSE route_count::int
         END AS route_count,
       tags->'station' AS station,
       COALESCE(tags->'short_name', name) AS label
     FROM stations_with_route_counts
     WHERE railway IN ('station', 'halt', 'service_station', 'yard', 'junction', 'spur_junction', 'crossover', 'site', 'tram_stop')
       AND (name IS NOT NULL OR tags ? 'short_name')
    ) AS r
  ORDER by rank DESC NULLS LAST, route_count DESC NULLS LAST;

CREATE OR REPLACE VIEW railway_symbols AS
  SELECT
    way,
    railway,
    man_made,
    CASE
      WHEN railway = 'crossing' THEN -1::int
      WHEN railway = 'tram_stop' THEN 1::int
      ELSE 0
      END AS prio
  FROM openrailwaymap_osm_point
  WHERE railway IN ('crossing', 'level_crossing', 'phone', 'tram_stop', 'border', 'owner_change', 'radio')
  ORDER BY prio DESC;

CREATE OR REPLACE VIEW railway_text_med AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'proposed' THEN proposed_railway
      WHEN railway = 'construction' THEN construction_railway
      WHEN railway = 'razed' THEN razed_railway
      WHEN railway = 'abandoned' THEN abandoned_railway
      WHEN railway = 'disused' THEN disused_railway
      ELSE railway
    END as feature,
    CASE WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
         WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
         WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
         WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL AND highspeed = 'yes' THEN 2000
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
         WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
         WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
         WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
         WHEN railway IN ('preserved', 'construction') THEN 400
         WHEN railway = 'proposed' THEN 350
         WHEN railway = 'disused' THEN 300
         WHEN railway = 'abandoned' THEN 250
         WHEN railway = 'razed' THEN 200

         ELSE 50
      END AS rank,
    ref AS label
  FROM
    (SELECT
       way, railway, usage, service, tags->'highspeed' AS highspeed,
       tags->'disused:railway' AS disused_railway, tags->'abandoned:railway' AS abandoned_railway,
       tags->'razed:railway' AS razed_railway, tags->'construction:railway' AS construction_railway,
       tags->'proposed:railway' AS proposed_railway,
       ref,
       layer
     FROM openrailwaymap_osm_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'abandoned', 'razed', 'construction', 'proposed') AND (tunnel IS NULL OR tunnel = 'no')
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_text_high AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'proposed' THEN proposed_railway
      WHEN railway = 'construction' THEN construction_railway
      WHEN railway = 'razed' THEN razed_railway
      WHEN railway = 'abandoned' THEN abandoned_railway
      WHEN railway = 'disused' THEN disused_railway
      ELSE railway
    END as feature,
    CASE WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
         WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
         WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
         WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL AND highspeed = 'yes' THEN 2000
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
         WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
         WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
         WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
         WHEN railway IN ('preserved', 'construction') THEN 400
         WHEN railway = 'proposed' THEN 350
         WHEN railway = 'disused' THEN 300
         WHEN railway = 'abandoned' THEN 250
         WHEN railway = 'razed' THEN 200
         ELSE 50
      END AS rank,
    CASE
      WHEN ref IS NOT NULL AND label_name IS NOT NULL THEN ref || ' ' || label_name
      ELSE COALESCE(ref, label_name)
      END AS label
  FROM
    (SELECT
       way, railway, usage, service, tags->'highspeed' AS highspeed,
       tags->'disused:railway' AS disused_railway, tags->'abandoned:railway' AS abandoned_railway,
       tags->'razed:railway' AS razed_railway, tags->'construction:railway' AS construction_railway,
       tags->'proposed:railway' AS proposed_railway,
       tags, tunnel, bridge,
       ref,
       CASE
         WHEN railway = 'abandoned' THEN
           railway_label_name(COALESCE(tags->'abandoned:name',name), tags, tunnel, bridge)
         WHEN railway = 'razed' THEN
           railway_label_name(COALESCE(tags->'razed:name',name), tags, tunnel, bridge)
         ELSE railway_label_name(name, tags, tunnel, bridge)
         END AS label_name,
       layer
     FROM openrailwaymap_osm_line
     WHERE
       railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'abandoned', 'razed', 'construction', 'proposed')
       AND (ref IS NOT NULL OR name IS NOT NULL OR tags ? 'bridge:name' OR tags ? 'tunnel:name')
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_text_km_med AS
  SELECT
    way,
    railway,
    pos
  FROM
    (SELECT
       way,
       railway,
       COALESCE(railway_position, railway_pos_round(railway_position_detail)::text) AS pos
     FROM openrailwaymap_osm_point
     WHERE railway IN ('milestone', 'level_crossing', 'crossing')
       AND (railway_position IS NOT NULL OR railway_position_detail IS NOT NULL)
    ) AS r
  WHERE railway_pos_decimal(pos) = '0';

CREATE OR REPLACE VIEW railway_text_km_high AS
  SELECT
    way,
    railway,
    pos
  FROM
    (SELECT
       way,
       railway,
       COALESCE(railway_position, railway_pos_round(railway_position_detail)::text) AS pos
     FROM openrailwaymap_osm_point
     WHERE railway IN ('milestone', 'level_crossing', 'crossing')
       AND (railway_position IS NOT NULL OR railway_position_detail IS NOT NULL)
    ) AS r
  WHERE pos IS NOT NULL
  ORDER by (railway_pos_decimal(pos) = '0');

CREATE OR REPLACE VIEW railway_switch_ref AS
  SELECT
    way, railway, ref, railway_local_operated
  FROM openrailwaymap_osm_point
  WHERE railway IN ('switch', 'railway_crossing') AND ref IS NOT NULL
  ORDER by char_length(ref) ASC;

CREATE OR REPLACE VIEW railway_text_detail AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'proposed' THEN proposed_railway
      WHEN railway = 'construction' THEN construction_railway
      WHEN railway = 'razed' THEN razed_railway
      WHEN railway = 'abandoned' THEN abandoned_railway
      WHEN railway = 'disused' THEN disused_railway
      ELSE railway
    END as feature,
    CASE WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
         WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
         WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
         WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
         WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL AND highspeed = 'yes' THEN 2000
         WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
         WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
         WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
         WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
         WHEN railway IN ('preserved', 'construction') THEN 400
         WHEN railway = 'proposed' THEN 350
         WHEN railway = 'disused' THEN 300
         WHEN railway = 'abandoned' THEN 250
         WHEN railway = 'razed' THEN 200
         ELSE 50
      END AS rank,
    CASE
      WHEN ref IS NOT NULL AND label_name IS NOT NULL THEN ref || ' ' || label_name
      ELSE COALESCE(ref, label_name)
    END AS label,
    track_ref
  FROM
    (SELECT
       way, railway, usage, service, tags->'highspeed' AS highspeed,
       tags->'disused' AS disused, tags->'abandoned' AS abandoned, tags->'razed' AS razed, construction, tags->'proposed' AS proposed,
       tags->'disused:railway' AS disused_railway, tags->'abandoned:railway' AS abandoned_railway,
       tags->'razed:railway' AS razed_railway, tags->'construction:railway' AS construction_railway,
       tags->'proposed:railway' AS proposed_railway,
       tags,
       name, ref,
       tags->'railway:track_ref' AS track_ref,
       tunnel, bridge,
       CASE
         WHEN railway = 'abandoned' THEN
           railway_label_name(COALESCE(tags->'abandoned:name',name), tags, tunnel, bridge)
         WHEN railway = 'razed' THEN
           railway_label_name(COALESCE(tags->'razed:name',name), tags, tunnel, bridge)
         ELSE railway_label_name(name, tags, tunnel, bridge)
         END AS label_name,
       layer
     FROM openrailwaymap_osm_line
     WHERE
       railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'abandoned', 'razed', 'construction', 'proposed')
       AND (ref IS NOT NULL OR name IS NOT NULL OR tags ? 'bridge:name' OR tags ? 'tunnel:name' OR tags ? 'railway:track_ref')
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW railway_line AS
  SELECT
    way,
    railway,
    usage,
    service,
    layer,
    CASE
      WHEN railway = 'construction' THEN tags->'construction:railway'
      WHEN railway = 'disused' THEN tags->'disused:railway'
      WHEN railway = 'preserved' THEN tags->'preserved:railway'
      ELSE railway
    END as feature,
    railway_train_protection_rank(
      tags->'railway:pzb',
      railway_null_to_no(tags->'railway:lzb'),
      tags->'railway:atb',
      tags->'railway:atb-eg',
      tags->'railway:atb-ng',
      tags->'railway:atb-vv',
      tags->'railway:atc',
      tags->'railway:kvb',
      tags->'railway:tvm',
      tags->'railway:scmt',
      tags->'railway:asfa',
      railway_null_or_zero_to_no(tags->'railway:ptc'),
      tags->'railway:zsi127',
      railway_null_or_zero_to_no(tags->'railway:etcs'),
      railway_null_or_zero_to_no(tags->'construction:railway:etcs')
    ) as rank,
    CASE
      WHEN railway_null_or_zero_to_no(tags->'railway:etcs') != 'no' THEN 'etcs'
      WHEN railway_null_or_zero_to_no(tags->'railway:ptc') != 'no' THEN 'ptc'
      WHEN railway_null_or_zero_to_no(tags->'construction:railway:etcs') != 'no' THEN 'construction_etcs'
      WHEN tags->'railway:asfa' = 'yes' THEN 'asfa'
      WHEN tags->'railway:scmt' = 'yes' THEN 'scmt'
      WHEN railway_null_or_zero_to_no(tags->'railway:tvm') != 'no' THEN 'tvm'
      WHEN tags->'railway:kvb' = 'yes' THEN 'kvb'
      WHEN tags->'railway:atc' = 'yes' THEN 'atc'
      WHEN COALESCE(tags->'railway:atb', tags->'railway:atb-eg', tags->'railway:atb-ng', tags->'railway:atb-vv') = 'yes' THEN 'atb'
      WHEN tags->'railway:zsi127' = 'yes' THEN 'zsi127'
      WHEN tags->'railway:lzb' = 'yes' THEN 'lzb'
      WHEN tags->'railway:pzb' = 'yes' THEN 'pzb'
      WHEN (tags->'railway:pzb' = 'no' AND tags->'railway:lzb' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:atb' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:atc' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:scmt' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:asfa' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:kvb' = 'no' AND tags->'railway:tvm' = 'no' AND tags->'railway:etcs' = 'no') OR (tags->'railway:zsi127' = 'no') THEN 'other'
    END as train_protection
    FROM openrailwaymap_osm_line
    WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'preserved', 'construction')
    ORDER BY
      COALESCE(layer, 0),
      rank NULLS LAST;

CREATE OR REPLACE VIEW signal_boxes_point AS
  SELECT
    way
  FROM (
    SELECT
        way
      FROM openrailwaymap_osm_point
      WHERE railway = 'signal_box'
  ) AS boxes;

CREATE OR REPLACE VIEW signal_boxes_polygon AS
  SELECT
    way
  FROM openrailwaymap_osm_polygon
  WHERE
    railway = 'signal_box'
;

CREATE OR REPLACE VIEW railway_signals AS
  WITH pre_signals AS (
    SELECT
      way,
      railway,
      ref,
      COALESCE(
          tags->'railway:signal:combined',
          tags->'railway:signal:main',
          tags->'railway:signal:distant',
          tags->'railway:signal:train_protection',
          tags->'railway:signal:main_repeated',
          tags->'railway:signal:minor',
          tags->'railway:signal:passing',
          tags->'railway:signal:shunting',
          tags->'railway:signal:stop',
          tags->'railway:signal:stop_demand',
          tags->'railway:signal:station_distant',
          tags->'railway:signal:crossing_distant',
          tags->'railway:signal:crossing',
          tags->'railway:signal:ring',
          tags->'railway:signal:whistle',
          tags->'railway:signal:departure',
          tags->'railway:signal:main_repeated',
          tags->'railway:signal:humping',
          tags->'railway:signal:speed_limit'
      ) AS feature,
      COALESCE(
          tags->'railway:signal:combined:deactivated',
          tags->'railway:signal:main:deactivated',
          tags->'railway:signal:distant:deactivated',
          tags->'railway:signal:train_protection:deactivated',
          tags->'railway:signal:main_repeated:deactivated',
          tags->'railway:signal:minor:deactivated',
          tags->'railway:signal:passing:deactivated',
          tags->'railway:signal:shunting:deactivated',
          tags->'railway:signal:stop:deactivated',
          tags->'railway:signal:stop_demand:deactivated',
          tags->'railway:signal:station_distant:deactivated',
          tags->'railway:signal:crossing_distant:deactivated',
          tags->'railway:signal:crossing:deactivated',
          tags->'railway:signal:ring:deactivated',
          tags->'railway:signal:whistle:deactivated',
          tags->'railway:signal:departure:deactivated',
          tags->'railway:signal:main_repeated:deactivated',
          tags->'railway:signal:humping:deactivated',
          tags->'railway:signal:speed_limit:deactivated'
      ) = 'yes' AS deactivated,
      tags->'railway:signal:passing:caption' AS passing_caption,
      tags->'railway:signal:stop:caption' AS stop_caption,
      tags->'railway:signal:combined:deactivated' AS combined_deactivated,
      tags->'railway:signal:main:deactivated' AS main_deactivated,
      tags->'railway:signal:distant:deactivated' AS distant_deactivated,
      tags->'railway:signal:train_protection:deactivated' AS train_protection_deactivated,
      tags->'railway:signal:main_repeated:deactivated' AS main_repeated_deactivated,
      tags->'railway:signal:wrong_road' AS wrong_road,
      tags->'railway:signal:wrong_road:form' AS wrong_road_form,
      tags->'railway:signal:minor:deactivated' AS minor_deactivated,
      tags->'railway:signal:passing:deactivated' AS passing_deactivated,
      tags->'railway:signal:shunting:deactivated' AS shunting_deactivated,
      tags->'railway:signal:stop:deactivated' AS stop_deactivated,
      tags->'railway:signal:stop_demand:deactivated' AS stop_demand_deactivated,
      tags->'railway:signal:station:distant:deactivated' AS station_distant_deactivated,
      tags->'railway:signal:crossing:distant:deactivated' AS crossing_distant_deactivated,
      tags->'railway:signal:crossing:deactivated' AS crossing_deactivated,
      tags->'railway:signal:ring:deactivated' AS ring_deactivated,
      tags->'railway:signal:whistle:deactivated' AS whistle_deactivated,
      tags->'railway:signal:departure:deactivated' AS departure_deactivated,
      tags->'railway:signal:combined:form' AS combined_form,
      tags->'railway:signal:main:form' AS main_form,
      tags->'railway:signal:distant:form' AS distant_form,
      tags->'railway:signal:train_protection:form' AS train_protection_form,
      tags->'railway:signal:main_repeated:form' AS main_repeated_form,
      tags->'railway:signal:minor:form' AS minor_form,
      tags->'railway:signal:passing:form' AS passing_form,
      tags->'railway:signal:shunting:form' AS shunting_form,
      tags->'railway:signal:stop:form' AS stop_form,
      tags->'railway:signal:stop_demand:form' AS stop_demand_form,
      tags->'railway:signal:station:distant:form' AS station_distant_form,
      tags->'railway:signal:crossing:distant:form' AS crossing_distant_form,
      tags->'railway:signal:crossing:form' AS crossing_form,
      tags->'railway:signal:ring:form' AS ring_form,
      tags->'railway:signal:whistle:form' AS whistle_form,
      tags->'railway:signal:departure:form' AS departure_form,
      tags->'railway:signal:humping:form' AS humping_form,
      tags->'railway:signal:speed_limit:form' AS speed_limit_form,
      tags->'railway:signal:combined:height' AS combined_height,
      tags->'railway:signal:main:height' AS main_height,
      tags->'railway:signal:distant:height' AS distant_height,
      tags->'railway:signal:train_protection:height' AS train_protection_height,
      tags->'railway:signal:minor:height' AS minor_height,
      tags->'railway:signal:passing:height' AS passing_height,
      tags->'railway:signal:shunting:height' AS shunting_height,
      tags->'railway:signal:stop:height' AS stop_height,
      tags->'railway:signal:stop_demand:height' AS stop_demand_height,
      tags->'railway:signal:station:distant:height' AS station_distant_height,
      tags->'railway:signal:crossing:distant:height' AS crossing_distant_height,
      tags->'railway:signal:crossing:height' AS crossing_height,
      tags->'railway:signal:ring:height' AS ring_height,
      tags->'railway:signal:whistle:height' AS whistle_height,
      tags->'railway:signal:departure:height' AS departure_height,
      tags->'railway:signal:combined:states' AS combined_states,
      tags->'railway:signal:main:states' AS main_states,
      tags->'railway:signal:distant:states' AS distant_states,
      tags->'railway:signal:train_protection:states' AS train_protection_states,
      tags->'railway:signal:minor:states' AS minor_states,
      tags->'railway:signal:passing:states' AS passing_states,
      tags->'railway:signal:shunting:states' AS shunting_states,
      tags->'railway:signal:stop:states' AS stop_states,
      tags->'railway:signal:stop_demand:states' AS stop_demand_states,
      tags->'railway:signal:station:distant:states' AS station_distant_states,
      tags->'railway:signal:crossing:distant:states' AS crossing_distant_states,
      tags->'railway:signal:crossing:states' AS crossing_states,
      tags->'railway:signal:ring:states' AS ring_states,
      tags->'railway:signal:whistle:states' AS whistle_states,
      tags->'railway:signal:departure:states' AS departure_states,
      tags->'railway:signal:main_repeated:states' AS main_repeated_states,
      tags->'railway:signal:humping:states' AS humping_states,
      tags->'railway:signal:speed_limit:states' AS speed_limit_states,
      tags->'railway:signal:combined:repeated' AS combined_repeated,
      tags->'railway:signal:main:repeated' AS main_repeated,
      tags->'railway:signal:distant:repeated' AS distant_repeated,
      tags->'railway:signal:train_protection:repeated' AS train_protection_repeated,
      tags->'railway:signal:minor:repeated' AS minor_repeated,
      tags->'railway:signal:passing:repeated' AS passing_repeated,
      tags->'railway:signal:shunting:repeated' AS shunting_repeated,
      tags->'railway:signal:stop:repeated' AS stop_repeated,
      tags->'railway:signal:stop_demand:repeated' AS stop_demand_repeated,
      tags->'railway:signal:station:distant:repeated' AS station_distant_repeated,
      tags->'railway:signal:crossing:distant:repeated' AS crossing_distant_repeated,
      tags->'railway:signal:crossing:repeated' AS crossing_repeated,
      tags->'railway:signal:ring:repeated' AS ring_repeated,
      tags->'railway:signal:whistle:repeated' AS whistle_repeated,
      tags->'railway:signal:departure:repeated' AS departure_repeated,
      tags->'railway:signal:combined:shortened' AS combined_shortened,
      tags->'railway:signal:main:shortened' AS main_shortened,
      tags->'railway:signal:distant:shortened' AS distant_shortened,
      tags->'railway:signal:train_protection:shortened' AS train_protection_shortened,
      tags->'railway:signal:minor:shortened' AS minor_shortened,
      tags->'railway:signal:passing:shortened' AS passing_shortened,
      tags->'railway:signal:shunting:shortened' AS shunting_shortened,
      tags->'railway:signal:stop:shortened' AS stop_shortened,
      tags->'railway:signal:stop_demand:shortened' AS stop_demand_shortened,
      tags->'railway:signal:station:distant:shortened' AS station_distant_shortened,
      tags->'railway:signal:crossing:distant:shortened' AS crossing_distant_shortened,
      tags->'railway:signal:crossing:shortened' AS crossing_shortened,
      tags->'railway:signal:ring:shortened' AS ring_shortened,
      tags->'railway:signal:whistle:shortened' AS whistle_shortened,
      tags->'railway:signal:departure:shortened' AS departure_shortened,
      tags->'railway:signal:combined:only_transit' AS combined_only_transit,
      tags->'railway:signal:main:only_transit' AS main_only_transit,
      tags->'railway:signal:distant:only_transit' AS distant_only_transit,
      tags->'railway:signal:train_protection:only_transit' AS train_protection_only_transit,
      tags->'railway:signal:minor:only_transit' AS minor_only_transit,
      tags->'railway:signal:passing:only_transit' AS passing_only_transit,
      tags->'railway:signal:shunting:only_transit' AS shunting_only_transit,
      tags->'railway:signal:stop:only_transit' AS stop_only_transit,
      tags->'railway:signal:stop_demand:only_transit' AS stop_demand_only_transit,
      tags->'railway:signal:station:distant:only_transit' AS station_distant_only_transit,
      tags->'railway:signal:crossing:distant:only_transit' AS crossing_distant_only_transit,
      tags->'railway:signal:crossing:only_transit' AS crossing_only_transit,
      tags->'railway:signal:ring:only_transit' AS ring_only_transit,
      tags->'railway:signal:whistle:only_transit' AS whistle_only_transit,
      tags->'railway:signal:departure:only_transit' AS departure_only_transit,
      tags->'railway:signal:combined:type' AS combined_type,
      tags->'railway:signal:main:type' AS main_type,
      tags->'railway:signal:distant:type' AS distant_type,
      tags->'railway:signal:train_protection:type' AS train_protection_type,
      tags->'railway:signal:minor:type' AS minor_type,
      tags->'railway:signal:passing:type' AS passing_type,
      tags->'railway:signal:shunting:type' AS shunting_type,
      tags->'railway:signal:stop:type' AS stop_type,
      tags->'railway:signal:stop_demand:type' AS stop_demand_type,
      tags->'railway:signal:station:distant:type' AS station_distant_type,
      tags->'railway:signal:crossing:distant:type' AS crossing_distant_type,
      tags->'railway:signal:crossing:type' AS crossing_type,
      tags->'railway:signal:ring:type' AS ring_type,
      tags->'railway:signal:whistle:type' AS whistle_type,
      tags->'railway:signal:departure:type' AS departure_type,
      tags->'railway:signal:train_protection:shape' AS train_protection_shape,
      tags
    FROM openrailwaymap_osm_signals
    WHERE
      (railway IN ('signal', 'buffer_stop'))
        AND "signal_direction" IS NOT NULL
       OR railway = 'derail'
  )
  SELECT
    way,
    railway,
    ref,
    deactivated,
    CASE

      -- AT --

      -- AT shunting light signals (Verschubverbot)
      WHEN feature = 'AT-V2:verschubsignal' AND shunting_form = 'light' THEN 'at:verschubverbot-aufgehoben'

      -- AT minor light signals (Sperrsignale) as sign
      WHEN feature = 'AT-V2:weiterfahrt_verboten' AND minor_form = 'sign' THEN 'at:weiterfahrt-verboten'

      -- AT minor light signals (Sperrsignale) as semaphore signals
      WHEN feature = 'AT-V2:sperrsignal' AND minor_form = 'semaphore' THEN 'at:weiterfahrt-erlaubt'

      -- AT distant light signals
      WHEN feature = 'AT-V2:vorsignal' AND distant_form = 'light' THEN
        CASE
          WHEN distant_states ~ '^(.*;)?AT-V2:hauptsignal_frei_mit_60(;.*)?$' THEN 'at:vorsignal-hauptsignal-frei-mit-60'
          WHEN distant_states ~ '^(.*;)?AT-V2:hauptsignal_frei_mit_(2|4)0(;.*)?$' THEN 'at:vorsignal-hauptsignal-frei-mit-40'
          WHEN distant_states ~ '^(.*;)?AT-V2:hauptsignal_frei(;.*)?$' THEN 'at:vorsignal-hauptsignal-frei'
          ELSE 'at:vorsignal-vorsicht'
        END

      -- AT distant semaphore signals
      WHEN feature = 'AT-V2:vorsignal' AND distant_form = 'semaphore' THEN 'at:vorsicht-semaphore'

      -- AT main light signals
      WHEN feature = 'AT-V2:hauptsignal' AND main_form = 'light' THEN
        CASE
          WHEN main_states ~ '^(.*;)?AT-V2:frei_mit_60(;.*)?$' THEN 'at:hauptsignal-frei-mit-60'
          WHEN main_states ~ '^(.*;)?AT-V2:frei_mit_(2|4)0(;.*)?$' THEN 'at:hauptsignal-frei-mit-40'
          WHEN main_states ~ '^(.*;)?AT-V2:frei(;.*)?$' THEN 'at:hauptsignal-frei'
          ELSE 'at:hauptsignal-halt'
        END

      -- DE --

      -- DE crossing distant sign Bü 2
      WHEN feature = 'DE-ESO:db:bü4' THEN
        CASE
          WHEN ring_only_transit = 'yes' THEN 'bue4-ds-only-transit'
          ELSE 'de:bue4-ds'
        END

      -- DE whistle sign Bü 4 (DS 301)
      WHEN feature = 'DE-ESO:bü2' THEN
        CASE
          WHEN  crossing_distant_shortened = 'yes' THEN 'de:bue2-ds-reduced-distance'
          ELSE 'de:bue2-ds'
        END

      -- DE whistle sign Pf 1 (DV 301)
      WHEN feature = 'DE-ESO:dr:pf1' THEN
        CASE
          WHEN ring_only_transit = 'yes' THEN 'de:pf1-dv-only-transit'
          ELSE 'de:pf1-dv'
        END

      -- DE ring sign Bü 5
      WHEN feature = 'DE-ESO:bü5' THEN
        CASE
          WHEN  ring_only_transit = 'yes' THEN 'de:bue5-only-transit'
          ELSE 'de:bue5'
        END

      -- DE crossing signal Bü 0/1
      WHEN feature = 'DE-ESO:bü' THEN
        CASE
          WHEN crossing_form = 'sign' THEN
            CASE
              WHEN crossing_repeated = 'yes' THEN 'de:bue0-ds-repeated'
              WHEN crossing_shortened = 'yes' THEN 'de:bue0-ds-shortened'
              ELSE 'de:bue0-ds'
            END
          WHEN crossing_repeated = 'yes' THEN 'de:bue1-ds-repeated'
          WHEN crossing_shortened = 'yes' THEN 'de:bue1-ds-shortened'
          ELSE 'de:bue1-ds'
        END

      -- DE crossing signal Bü 0/1 (ex. So 16a/b) which can show Bü 1 (ex. So 16b)
      WHEN feature = 'DE-ESO:so16' AND crossing_form = 'light' THEN
        CASE
          WHEN crossing_repeated = 'yes' THEN 'de:bue1-dv-repeated'
          WHEN crossing_shortened = 'yes' THEN 'de:bue1-dv-shortened'
          ELSE 'de:bue1-dv'
        END

      -- DE tram signal "start of train protection" So 1
      WHEN feature IN ('DE-BOStrab:so1', 'DE-AVG:so1') AND train_protection_form = 'sign' AND train_protection_type = 'start' THEN 'de:bostrab/so1'

      -- DE tram signal "end of train protection" So 2
      WHEN feature IN ('DE-BOStrab:so2', 'DE-AVG:so2') AND train_protection_form = 'sign' AND train_protection_type = 'end' THEN 'de:bostrab/so2'

      -- DE station distant sign Ne 6
      WHEN feature = 'DE-ESO:ne6' AND station_distant_form = 'sign' THEN 'de:ne6'

      -- DE stop demand post Ne 5 (light)
      WHEN feature = 'DE-ESO:ne5' AND stop_demand_form = 'light' AND stop_form IS NULL THEN 'de:ne5-light'

      -- DE stop demand post Ne 5 (sign)
      WHEN feature = 'DE-ESO:ne5' AND stop_demand_form IS NULL AND stop_form = 'sign' THEN 'de:ne5-sign'

      -- DE shunting stop sign Ra 10
      -- AT shunting stop sign "Verschubhalttafel"
      WHEN feature IN ('DE-ESO:ra10', 'AT-V2:verschubhalttafel') AND shunting_form = 'sign' THEN 'de:ra10'

      -- DE wrong road signal Zs 6 (DB) / Zs 7 (DR)
      WHEN wrong_road = 'DE-ESO:db:zs6' AND wrong_road_form = 'sign' THEN 'de:zs6-sign'
      WHEN wrong_road = 'DE-ESO:db:zs6' AND wrong_road_form = 'light' THEN 'de:zs6-light'
      WHEN wrong_road = 'DE-ESO:db:zs7' AND wrong_road_form = 'light' THEN 'de:zs7-dr-light'

      -- DE tram minor stop sign Sh 1
      WHEN feature = 'DE-BOStrab:sh1' AND minor_form = 'sign' THEN 'de:bostrab/sh1'

      -- DE tram passing prohibited sign So 5
      WHEN feature = 'DE-BOStrab:so5' AND passing_form = 'sign' AND passing_type = 'no_type' THEN 'de:bostrab/so5'

      -- DE tram passing prohibited end sign So 6
      WHEN feature = 'DE-BOStrab:so6' AND passing_form = 'sign' AND passing_type = 'passing_allowed' THEN 'de:bostrab/so6'

      -- DE shunting signal Ra 11 without Sh 1
      -- AT Wartesignal ohne "Verschubverbot aufgehoben"
      WHEN feature IN ('DE-ESO:ra11', 'AT-V2:wartesignal') AND shunting_form = 'sign' THEN 'de:ra11-sign'

      -- DE shunting signal Ra 11 with Sh 1
      WHEN feature = 'DE-ESO:ra11' AND shunting_form = 'light' THEN 'de:ra11-sh1'

      -- DE shunting signal Ra 11b (without Sh 1)
      WHEN feature = 'DE-ESO:ra11b' AND shunting_form = 'sign' THEN 'de:ra11b'

      -- DE minor light signals type Sh
      WHEN feature = 'DE-ESO:sh' AND minor_form = 'light' THEN
        CASE
          WHEN (minor_height = 'normal' AND (minor_states IS NULL OR minor_states ~ '^(.*;)?DE-ESO:sh1(;.*)?$'))
            OR (minor_height IS NULL AND minor_states IS NULL)
          THEN 'de:sh1-light-normal'
          ELSE 'de:sh0-light-dwarf'
        END

      -- DE minor semaphore signals and signs type Sh
      WHEN (feature = 'DE-ESO:sh' AND minor_form = 'semaphore')
        OR (feature = 'DE-ESO:sh0' AND minor_form = 'sign')
      THEN
        CASE
          WHEN minor_states ~ '^(.*;)?DE-ESO:wn7(;.*)?$' THEN 'de:wn7-semaphore-normal'
          WHEN minor_form = 'semaphore' AND (minor_height IS NULL or minor_height = 'normal') THEN 'de:sh1-semaphore-normal'
          ELSE 'de:sh0-semaphore-dwarf'
        END

      -- DE signal Sh 2 as signal and at buffer stops
      WHEN feature IN ('DE-ESO:sh2', 'DE-BOStrab:sh2') THEN 'de:sh2'

      -- DE Signalhaltmelder Zugleitbetrieb
      --   repeats DE-ESO:hp0 of the entrance main signal to the halt position
      WHEN feature = 'DE-DB:signalhaltmelder' AND main_repeated_form = 'light' THEN 'de:zlb-haltmelder-light'

      -- DE main entry sign Ne 1
      WHEN feature IN ('DE-ESO:bü2', 'AT-V2:trapeztafel') AND main_form = 'sign' THEN 'de:ne1'

      -- DE distant light signals type Vr which
      --  - are repeaters or shortened
      --  - have no railway:signal:states=* tag
      --  - OR have railway:signal:states=* tag that does neither include Vr1 nor Vr2
      WHEN feature = 'DE-ESO:vr' AND distant_form = 'light' THEN
        CASE
          WHEN distant_shortened = 'yes' OR distant_repeated = 'yes' THEN
          CASE
            WHEN distant_states ~ '^(.*;)?DE-ESO:vr2(;.*)?$' THEN 'de:vr2-light-repeated'
            WHEN distant_states ~ '^(.*;)?DE-ESO:vr1(;.*)?$' THEN 'de:vr1-light-repeated'
            ELSE 'de:vr0-light-repeated'
          END
          WHEN distant_states ~ '^(.*;)?DE-ESO:vr2(;.*)?$' THEN 'de:vr2-light'
          WHEN distant_states ~ '^(.*;)?DE-ESO:vr1(;.*)?$' THEN 'de:vr1-light'
          ELSE 'de:vr0-light'
        END

      -- DE distant semaphore signals type Vr which
      --  - have no railway:signal:states=* tag
      --  - OR have railway:signal:states=* tag that does neither include Vr1 nor Vr2
      WHEN feature = 'DE-ESO:vr' AND distant_form = 'semaphore' THEN
        CASE
          WHEN distant_states ~ '^(.*;)?DE-ESO:vr2(;.*)?$' THEN 'de:vr2-semaphore'
          WHEN distant_states ~ '^(.*;)?DE-ESO:vr1(;.*)?$' THEN 'de:vr1-semaphore'
          ELSE 'de:vr0-semaphore'
        END

      -- DE Hamburger Hochbahn distant signal
      WHEN feature = 'DE-HHA:v' AND distant_form = 'light' THEN 'de:hha/v1'

      -- DE block marker ("Blockkennzeichen")
      -- TODO adopt flex/de/blockkennzeichen-[width]x[height]
      WHEN feature = 'DE-ESO:blockkennzeichen' THEN 'de:blockkennzeichen'

      -- DE distant signal replacement by sign So 106
      -- AT Kreuztafel
      WHEN feature IN ('DE-ESO:so106', 'AT-V2:kreuztafel') AND distant_form = 'sign' THEN 'de:so106'

      -- DE distant signal replacement by sign Ne 2
      WHEN feature = 'DE-ESO:db:ne2' AND distant_form = 'sign' THEN
        CASE
          WHEN distant_shortened = 'yes' THEN 'de:ne2-reduced-distance'
          ELSE 'de:ne2'
        END

      -- DE main semaphore signals type Hp
      -- AT main semaphore signal "Hauptsignal"
      WHEN feature IN ('DE-ESO:hp', 'AT-V2:hauptsignal') AND main_form = 'semaphore' THEN
        CASE
          WHEN main_states ~ '^(.*;)?(DE-ESO:hp2|AT-V2:frei_mit_(4|2)0)(;.*)?$' THEN 'de:hp2-semaphore'
          WHEN main_states ~ '^(.*;)?(DE-ESO:hp1|AT-V2:frei)(;.*)?$' THEN 'de:hp1-semaphore'
          ELSE 'de:hp0-semaphore'
        END

      -- DE main light signals type Hp
      WHEN feature = 'DE-ESO:hp' AND main_form = 'light' THEN
        CASE
          WHEN main_states ~ '^(.*;)?DE-ESO:hp2(;.*)?$' THEN 'de:hp2-light'
          WHEN main_states ~ '^(.*;)?DE-ESO:hp1(;.*)?$' THEN 'de:hp1-light'
          ELSE 'de:hp0-light'
        END

      -- DE main, combined and distant light signals type Hl
      WHEN feature = 'DE-ESO:hl' AND main_form = 'light' THEN
        CASE
          WHEN main_form IS NULL AND distant_form = 'light' AND combined_form IS NULL THEN 'de:hl1-distant'
          WHEN main_form = 'light' AND distant_form IS NULL AND combined_form IS NULL THEN
            CASE
              WHEN main_states ~ '^(.*;)?DE-ESO:hl2(;.*)?$' THEN 'de:hl2'
              WHEN main_states ~ '^(.*;)?DE-ESO:hl3b(;.*)?$' THEN 'de:hl3b'
              WHEN main_states ~ '^(.*;)?DE-ESO:hl3a(;.*)?$' THEN 'de:hl3a'
              WHEN main_states ~ '^(.*;)?DE-ESO:hl1(;.*)?$' THEN 'de:hl1'
              ELSE 'de:hl0'
            END
          WHEN main_form IS NULL AND distant_form IS NULL AND combined_form = 'light' THEN
            CASE
              WHEN combined_states ~ '^(.*;)?DE-ESO:hl11(;.*)?$' THEN 'de:hl11'
              WHEN combined_states ~ '^(.*;)?DE-ESO:hl12b(;.*)?$' THEN 'de:hl12b'
              WHEN combined_states ~ '^(.*;)?DE-ESO:hl12a(;.*)?$' THEN 'de:hl12a'
              WHEN combined_states ~ '^(.*;)?DE-ESO:hl10(;.*)?$' THEN 'de:hl10'
              ELSE 'de:hl0'
            END
          ELSE ''
        END

      -- DE combined light signals type Sv
      WHEN feature = 'DE-ESO:sv' THEN
        CASE
          WHEN combined_states ~ '^(.*;)?DE-ESO:hp0(;.*)?$' THEN 'de:hp0'
          WHEN combined_states ~ '^(.*;)?DE-ESO:sv0(;.*)?$' THEN 'de:sv0'
          ELSE ''
        END

      -- DE tram main signal "Fahrsignal"
      WHEN feature IN ('DE-AVG:f', 'DE-BOStrab:f') AND main_form = 'light' THEN
        CASE
          WHEN main_states ~ '^(.*;)?DE-BOStrab:f3(;.*)?$' THEN 'de:bostrab/f3'
          WHEN main_states ~ '^(.*;)?DE-BOStrab:f2(;.*)?$' THEN 'de:bostrab/f2'
          WHEN main_states ~ '^(.*;)?DE-BOStrab:f1(;.*)?$' THEN 'de:bostrab/f1'
          ELSE 'de:bostrab/f0'
        END

      -- DE Hamburger Hochbahn main signal
      WHEN feature = 'DE-HHA:h' AND main_form = 'light' THEN
        CASE
          WHEN main_states IS NULL THEN 'de:hha/h1'
          ELSE 'de:hha/h0'
        END

      -- DE main, combined and distant signals type Ks
      WHEN feature = 'DE-ESO:ks' THEN
        CASE
          WHEN main_form IS NULL AND distant_form = 'light' AND combined_form IS NULL THEN
            CASE
              WHEN distant_repeated = 'yes' THEN 'de:ks-distant-repeated'
              WHEN distant_shortened = 'yes' THEN 'de:ks-distant-shortened'
              ELSE 'de:ks-distant'
            END
          WHEN main_form = 'light' AND distant_form IS NULL AND combined_form IS NULL THEN 'ks-main'
          WHEN main_form IS NULL AND distant_form IS NULL AND combined_form = 'light' THEN
            CASE
              WHEN combined_shortened = 'yes' THEN 'de:ks-combined-shortened'
              ELSE 'de:ks-combined'
            END
          ELSE ''
        END


      -- FI --

      -- FI crossing signal To
      WHEN feature = 'FI:To' AND crossing_form = 'light' THEN 'fi:to1'

      -- FI shunting light signals type Ro (new)
      WHEN feature = 'FI:Ro' AND shunting_form = 'light' AND shunting_states ~ '^(.*;)?FI:Ro0(;.*)?$' THEN 'fi:ro0-new'

      -- FI minor light signals type Lo at moveable bridges
      WHEN feature = 'FI:Lo' AND minor_form = 'light' AND shunting_states ~ '^(.*;)?FI:Lo0(;.*)?$' THEN 'fi:lo0'

      -- FI distant light signals
      WHEN feature = 'FI:Eo' AND distant_form = 'light' AND distant_repeated != 'yes' THEN
        CASE
          WHEN distant_states ~ '^(.*;)?FI:Eo2(;.*)?$' THEN 'fi:eo2-new'
          WHEN distant_states ~ '^(.*;)?FI:Eo1(;.*)?$' THEN 'fi:eo1-new'
          ELSE 'fi:eo0-new'
        END
      WHEN feature = 'FI:Eo-v' AND distant_form = 'light' AND distant_repeated != 'yes' THEN
        CASE
          WHEN distant_states ~ '^(.*;)?FI:Eo1(;.*)?$' THEN 'fi:eo1-old'
          ELSE 'fi:eo0-old'
        END

      -- FI main light signals
      WHEN feature = 'FI:Po' AND main_form = 'light' THEN
        CASE
          WHEN main_states ~ '^(.*;)?FI:Po2(;.*)?$' THEN 'fi:po2-new'
          WHEN main_states ~ '^(.*;)?FI:Po1(;.*)?$' THEN 'fi:po1-new'
          ELSE 'fi:po0-new'
        END
      WHEN feature = 'FI:Po-v' AND main_form = 'light' THEN
        CASE
          WHEN main_states ~ '^(.*;)?FI:Po2(;.*)?$' THEN 'fi:po2-old'
          WHEN main_states ~ '^(.*;)?FI:Po1(;.*)?$' THEN 'fi:po1-old'
          ELSE 'fi:po0-old'
        END

      -- FI combined block signal type So
      WHEN feature = 'FI:So' AND combined_form = 'light' AND combined_states ~ '^(.*;)?FI:Po1(;.*)?$' AND combined_states ~ '^(.*;)?FI:Eo1(;.*)?$' THEN 'fi:eo1-po1-combined-block'


      -- NL --

      -- NL departure signals
      WHEN feature IN ('NL', 'NL:VL') AND departure_form = 'light' THEN 'nl:departure'

      WHEN feature = 'NL' THEN
        CASE
          -- NL dwarf shunting signals
          WHEN shunting_form = 'light' AND main_height = 'dwarf' THEN 'nl:main_light_dwarf_shunting'

          -- NL train protection block marker light
          WHEN train_protection_form = 'light' AND train_protection_type = 'block_marker' THEN 'nl:main_light_white_bar'

          -- NL main dwarf signals
          WHEN main_height = 'dwarf' THEN 'nl:main_light_dwarf'

          -- NL main shunting light
          WHEN shunting_form = 'light' THEN 'nl:main_light_shunting'

          -- NL distant light
          WHEN distant_form = 'light' THEN 'nl:distant_light'

          -- NL main repeated light
          WHEN (main_repeated_form = 'light' OR main_repeated_states = 'NL:272;NL:273') THEN 'nl:main_repeated_light'

          -- NL (freight) speed limits
          WHEN speed_limit_form = 'light' AND speed_limit_states = 'H;off' THEN 'nl:H'
          WHEN speed_limit_form = 'light' AND speed_limit_states = 'L;off' THEN 'nl:L'
          WHEN main_form = 'light' AND speed_limit_form = 'light' THEN 'nl:main_light_speed_limit'
          WHEN distant_form = 'light' AND speed_limit_form = 'light' THEN 'nl:distant_light_speed_limit'

          -- NL main light
          WHEN main_form = 'light' THEN 'nl:main_light'
          WHEN speed_limit_form = 'light' THEN 'nl:speed_limit_light'
          ELSE ''
        END

      -- NL Humping ("heuvelen")
      WHEN feature = 'NL:270' THEN 'nl:270a'

      -- NL ATB codewissel
      WHEN feature = 'NL:330' THEN 'nl:atb-codewissel'

      -- NL train protection block markers
      WHEN feature IN ('NL:227b', 'DE-ESO:ne14') AND train_protection_form = 'sign' AND train_protection_type = 'block_marker' THEN
        CASE
          WHEN feature = 'NL:227b' AND train_protection_shape = 'triangle' THEN 'general:etcs-stop-marker-arrow-left'
          ELSE 'general:etcs-stop-marker-triangle-left'
        END

      ELSE ''
    END as feature
  FROM pre_signals
  ORDER BY
    -- distant signals are less important, signals for slower speeds are more important
    (CASE
      WHEN railway_has_key(tags, 'railway:signal:main') THEN 10000
      WHEN railway_has_key(tags, 'railway:signal:combined') THEN 10000
      WHEN railway_has_key(tags, 'railway:signal:distant') THEN 9000
      WHEN railway_has_key(tags, 'railway:signal:train_protection') THEN 8500
      WHEN railway_has_key(tags, 'railway:signal:main_repeated') THEN 8000
      WHEN railway_has_key(tags, 'railway:signal:minor') THEN 4000
      WHEN railway_has_key(tags, 'railway:signal:passing') THEN 3500
      WHEN railway_has_key(tags, 'railway:signal:shunting') THEN 3000
      WHEN railway_has_key(tags, 'railway:signal:stop') THEN 1000
      WHEN railway_has_key(tags, 'railway:signal:stop_demand') THEN 900
      WHEN railway_has_key(tags, 'railway:signal:station_distant') THEN 550
      WHEN railway_has_key(tags, 'railway:signal:crossing') THEN 1000
      WHEN railway_has_key(tags, 'railway:signal:crossing_distant') THEN 500
      WHEN railway_has_key(tags, 'railway:signal:ring') THEN 500
      WHEN railway_has_key(tags, 'railway:signal:whistle') THEN 500
      WHEN railway_has_key(tags, 'railway:signal:departure') THEN 400
      ELSE 0
    END) ASC NULLS FIRST;

CREATE OR REPLACE VIEW signal_boxes_text AS
    (SELECT
        ST_PointOnSurface(way) AS way,
        tags->'railway:ref' AS ref,
        name
      FROM openrailwaymap_osm_polygon
      WHERE railway = 'signal_box'
    ORDER BY way_area DESC NULLS LAST)

    UNION ALL

    (SELECT
        way,
        tags->'railway:ref' AS ref,
        name
      FROM openrailwaymap_osm_point
      WHERE railway = 'signal_box');
