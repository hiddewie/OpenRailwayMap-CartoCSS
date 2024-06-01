--- Shared ---

CREATE OR REPLACE VIEW railway_line_low AS
  SELECT
    way,
    highspeed,
    -- speeds are converted to kph in this layer because it is used for colouring
    maxspeed,
    train_protection,
    train_protection_rank,
    railway_to_int(voltage) AS voltage,
    railway_to_float(frequency) AS frequency,
    railway_to_int(gauge) AS gaugeint0,
    gauge as gauge0
  FROM (
    SELECT
      way,
      railway_dominant_speed(preferred_direction, maxspeed, maxspeed_forward, maxspeed_backward) AS maxspeed,
      highspeed,
      train_protection,
      train_protection_rank,
      frequency,
      voltage,
      railway_desired_value_from_list(1, gauge) AS gauge
    FROM railway_line
    WHERE railway = 'rail' AND usage = 'main' AND service IS NULL
  ) AS r
  ORDER by
    highspeed,
    maxspeed NULLS FIRST;

CREATE OR REPLACE VIEW railway_line_med AS
  SELECT
    way,
    usage,
    highspeed,
    maxspeed,
    train_protection_rank,
    train_protection,
    electrification_state,
    voltage,
    frequency,
    railway_to_int(gauge) AS gaugeint0,
    gauge as gauge0
  FROM
    (SELECT
       way,
       railway,
       usage,
       highspeed,
       -- speeds are converted to kph in this layer because it is used for colouring
       railway_dominant_speed(preferred_direction, maxspeed, maxspeed_forward, maxspeed_backward) AS maxspeed,
       train_protection_rank,
       train_protection,
       railway_electrification_state(railway, electrified, deelectrified, abandoned_electrified, NULL, NULL, true) AS electrification_state,
       railway_to_int(voltage) AS voltage,
       railway_to_float(frequency) AS frequency,
       railway_desired_value_from_list(1, gauge) AS gauge
     FROM railway_line
     WHERE railway = 'rail' AND usage IN ('main', 'branch') AND service IS NULL
    ) AS r
  ORDER by
    CASE
      WHEN railway = 'rail' AND usage = 'main' AND highspeed THEN 2000
      WHEN railway = 'rail' AND usage = 'main' THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' THEN 1000
      ELSE 50
    END NULLS LAST,
    maxspeed NULLS FIRST;

--- Standard ---

CREATE OR REPLACE VIEW standard_railway_text_stations_low AS
  SELECT
    way,
    label
  FROM stations_with_route_counts
  WHERE
    railway = 'station'
    AND label IS NOT NULL
    AND route_count >= 8
  ORDER BY
    route_count DESC NULLS LAST;

CREATE OR REPLACE VIEW standard_railway_text_stations_med AS
  SELECT
    way,
    label
  FROM stations_with_route_counts
  WHERE
    railway = 'station'
    AND label IS NOT NULL
  ORDER BY
    route_count DESC NULLS LAST;

CREATE OR REPLACE VIEW standard_railway_line_fill AS
  SELECT
    way,
    railway,
    CASE
      WHEN railway = 'proposed' THEN COALESCE(proposed_railway, 'rail')
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'razed' THEN COALESCE(razed_railway, 'rail')
      WHEN railway = 'abandoned' THEN COALESCE(abandoned_railway, 'rail')
      WHEN railway = 'disused' THEN COALESCE(disused_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    usage,
    service,
    highspeed,
    (tunnel IS NOT NULL AND tunnel != 'no') as tunnel,
    (bridge IS NOT NULL AND bridge != 'no') as bridge,
    CASE
      WHEN ref IS NOT NULL AND label_name IS NOT NULL THEN ref || ' ' || label_name
      ELSE COALESCE(ref, label_name)
    END AS label,
    ref,
    track_ref,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
      WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
      WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
      WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
      WHEN railway = 'rail' AND usage = 'main' AND service IS NULL AND highspeed THEN 2000
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
       way,
       railway,
       usage,
       service,
       highspeed,
       disused_railway, abandoned_railway,
       razed_railway, construction_railway,
       proposed_railway,
       preserved_railway,
       layer,
       bridge,
       tunnel,
       track_ref,
       ref,
       CASE
         WHEN railway = 'abandoned' THEN railway_label_name(COALESCE(abandoned_name, name), tunnel, tunnel_name, bridge, bridge_name)
         WHEN railway = 'razed' THEN railway_label_name(COALESCE(razed_name, name), tunnel, tunnel_name, bridge, bridge_name)
         ELSE railway_label_name(name, tunnel, tunnel_name, bridge, bridge_name)
       END AS label_name
     FROM railway_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'abandoned', 'razed', 'construction', 'proposed', 'preserved')
    ) AS r
  ORDER by layer, rank NULLS LAST;

CREATE OR REPLACE VIEW standard_railway_text_stations AS
  SELECT
    way,
    railway,
    station,
    label,
    name,
    CASE
      WHEN railway = 'station' AND station = 'light_rail' THEN 450
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
    END AS rank
  FROM
    (SELECT
       way,
       railway,
       route_count,
       station,
       label,
       name
     FROM stations_with_route_counts
     WHERE railway IN ('station', 'halt', 'service_station', 'yard', 'junction', 'spur_junction', 'crossover', 'site')
       AND name IS NOT NULL
    ) AS r
  ORDER by rank DESC NULLS LAST, route_count DESC NULLS LAST;

CREATE OR REPLACE VIEW standard_railway_symbols AS
  SELECT
    way,
    CASE
      WHEN railway = 'crossing' THEN 'general/crossing'
      WHEN railway = 'level_crossing' THEN
        CASE
          WHEN crossing_barrier AND crossing_light AND crossing_bell THEN 'general/level-crossing-barrier'
          WHEN crossing_light AND crossing_bell THEN 'general/level-crossing-light'
          ELSE 'general/level-crossing'
        END
      WHEN railway = 'phone' THEN 'general/phone'
      WHEN railway = 'tram_stop' THEN 'general/tram-stop'
      WHEN railway = 'border' THEN 'general/border'
      WHEN railway = 'owner_change' THEN 'general/owner-change'
      WHEN railway = 'lubricator' THEN 'general/lubricator'
      WHEN railway = 'radio' THEN
        CASE
          WHEN man_made IN ('mast', 'tower') THEN 'general/radio-mast'
          WHEN man_made = 'antenna' THEN 'general/radio-antenna'
        END
    END AS feature,
    CASE
      WHEN railway = 'crossing' THEN -1::int
      WHEN railway = 'tram_stop' THEN 1::int
      ELSE 0
    END AS priority
  FROM pois
  WHERE railway IN ('crossing', 'level_crossing', 'phone', 'tram_stop', 'border', 'owner_change', 'radio', 'lubricator')
  ORDER BY priority DESC;

CREATE OR REPLACE VIEW standard_railway_text_km AS
  SELECT
    way,
    railway,
    pos,
    (railway_pos_decimal(pos) = '0') as zero
  FROM
    (SELECT
       way,
       railway,
       COALESCE(railway_position, railway_pos_round(railway_position_exact)::text) AS pos
     FROM railway_positions
    ) AS r
  WHERE pos IS NOT NULL
  ORDER by zero;

CREATE OR REPLACE VIEW standard_railway_switch_ref AS
  SELECT
    way,
    railway,
    ref,
    railway_local_operated
  FROM railway_switches
  ORDER by char_length(ref);


--- Speed ---

CREATE OR REPLACE VIEW speed_railway_line_fill AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'disused' THEN COALESCE(disused_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    -- speeds are converted to kph in this layer because it is used for colouring
    railway_dominant_speed(preferred_direction, maxspeed, maxspeed_forward, maxspeed_backward) AS maxspeed,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
      WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
      WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
      WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
      WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
      WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
      WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
      WHEN railway IN ('preserved', 'construction') THEN 400
      WHEN railway = 'disused' THEN 300
      ELSE 50
    END AS rank,
    railway_speed_label(speed_arr) AS label
  FROM
    (SELECT
       way,
       railway,
       usage,
       service,
       maxspeed,
       maxspeed_forward,
       maxspeed_backward,
       preferred_direction,
       -- does no unit conversion
       railway_direction_speed_limit(preferred_direction,maxspeed, maxspeed_forward, maxspeed_backward) AS speed_arr,
       disused_railway,
       construction_railway,
       preserved_railway,
       layer
     FROM railway_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'construction', 'preserved')
    ) AS r
  ORDER BY
    layer,
    rank NULLS LAST,
    maxspeed NULLS FIRST;

CREATE OR REPLACE VIEW speed_railway_signals AS
  SELECT
    way,
    CASE
        {% for feature in speed_railway_signals.features %}
        -- ({% feature.country %}) {% feature.description %}
        WHEN{% for tag in feature.tags %} "{% tag.tag %}"{% if tag.value %}='{% tag.value %}'{% elif tag.values %} IN ({% for value in tag.values %}{% unless loop.first %}, {% end %}'{% value %}'{% end %}){% end %}{% unless loop.last %} AND{% end %}{% end %}

          THEN {% if feature.icon.match %} CASE
            {% for case in feature.icon.cases %}
            WHEN "{% feature.icon.match %}" ~ '{% case.regex %}' THEN{% if case.value | contains("{}") %} CONCAT('{% case.value | regexReplace("\{\}.*$", "") %}', "{% feature.icon.match %}", '{% case.value | regexReplace("^.*\{\}", "") %}'){% else %} '{% case.value %}'{% end %}

{% end %}
            {% if feature.icon.default %}
            ELSE '{% feature.icon.default %}'
{% end %}
          END{% else %} '{% feature.icon.default %}'{% end %}


{% end %}

      END as feature,
    CASE
      {% for feature in speed_railway_signals.features %}
        {% if feature.type %}
        -- ({% feature.country %}) {% feature.description %}
        WHEN{% for tag in feature.tags %} "{% tag.tag %}"{% if tag.value %}='{% tag.value %}'{% elif tag.values %} IN ({% for value in tag.values %}{% unless loop.first %}, {% end %}'{% value %}'{% end %}){% end %}{% unless loop.last %} AND{% end %}{% end %} THEN '{% feature.type %}'

{% end %}
{% end %}

    END as type,
    azimuth,
    direction_both
  FROM (
    SELECT
      way,
      {% for tag in speed_railway_signals.tags %}
      {% unless tag | matches("railway:signal:speed_limit:speed") %}
      {% unless tag | matches("railway:signal:speed_limit_distant:speed") %}
      "{% tag %}",
{% end %}
{% end %}
{% end %}
      -- We cast the lowest speed to text to make it possible to only select those speeds in
      -- CartoCSS we have an icon for. Otherwise we might render an icon for 40 kph if
      -- 42 is tagged (but invalid tagging).
      railway_largest_speed_noconvert("railway:signal:speed_limit:speed")::text AS "railway:signal:speed_limit:speed",
      railway_largest_speed_noconvert("railway:signal:speed_limit_distant:speed")::text AS "railway:signal:speed_limit_distant:speed",
      azimuth,
      (signal_direction = 'both') as direction_both
    FROM signals_with_azimuth s
    WHERE railway = 'signal'
      AND signal_direction IS NOT NULL
      AND ("railway:signal:speed_limit" IS NOT NULL OR "railway:signal:speed_limit_distant" IS NOT NULL)
  ) AS feature_signals
  ORDER BY
    -- distant signals are less important, signals for slower speeds are more important
    ("railway:signal:speed_limit" IS NOT NULL) DESC NULLS FIRST,
    railway_speed_int(COALESCE("railway:signal:speed_limit:speed", "railway:signal:speed_limit_distant:speed")) DESC NULLS FIRST;


--- Signals ---

CREATE OR REPLACE VIEW signals_railway_line AS
  SELECT
    way,
    railway,
    usage,
    service,
    layer,
    CASE
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'disused' THEN COALESCE(disused_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    train_protection_rank,
    train_protection
  FROM railway_line
  WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'disused', 'preserved', 'construction')
  ORDER BY
    layer,
    train_protection_rank NULLS LAST;

CREATE OR REPLACE VIEW signals_signal_boxes AS
  SELECT
    way,
    ref,
    name
  FROM signal_boxes
  ORDER BY way_area DESC NULLS LAST;

CREATE OR REPLACE VIEW signals_railway_signals AS
  WITH pre_signals AS (SELECT
    way,
    railway,
    ref,
    ref_multiline,
    deactivated,
    CASE

        {% for feature in signals_railway_signals.features %}
        -- ({% feature.country %}) {% feature.description %}
        WHEN{% for tag in feature.tags %} "{% tag.tag %}"{% if tag.value %}='{% tag.value %}'{% elif tag.values %} IN ({% for value in tag.values %}{% unless loop.first %}, {% end %}'{% value %}'{% end %}){% end %}{% unless loop.last %} AND{% end %}{% end %}

          THEN {% if feature.icon.match %} CASE
            {% for case in feature.icon.cases %}
            WHEN "{% feature.icon.match %}" ~ '{% case.regex %}' THEN '{% case.value %}'

{% end %}
            {% if feature.icon.default %}
            ELSE '{% feature.icon.default %}'
{% end %}
          END{% else %} '{% feature.icon.default %}'{% end %}


{% end %}

    END as feature,
    azimuth,
    (signal_direction = 'both') as direction_both
  FROM signals_with_azimuth
  WHERE ((railway IN ('signal', 'buffer_stop') AND signal_direction IS NOT NULL)
    OR railway IN ('derail', 'vacancy_detection'))
  ORDER BY rank NULLS FIRST)
  SELECT
    way,
    railway,
    ref,
    ref_multiline,
    deactivated,
    feature,
    azimuth,
    direction_both
  FROM pre_signals
  -- TODO investigate signals with null features
  WHERE feature IS NOT NULL;

--- Electrification ---

CREATE OR REPLACE VIEW electrification_railway_line AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
      WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
      WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
      WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
      WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
      WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
      WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
      WHEN railway IN ('preserved', 'construction') THEN 400
      ELSE 50
    END AS rank,
    electrification_state_without_future AS electrification_state,
    railway_voltage_for_state(electrification_state_without_future, voltage, construction_voltage, proposed_voltage) AS voltage,
    railway_frequency_for_state(electrification_state_without_future, frequency, construction_frequency, proposed_frequency) AS frequency,
    label
  FROM
    (SELECT
       way,
       railway,
       usage,
       service,
       construction_railway,
       preserved_railway,
       railway_electrification_state(railway, electrified, deelectrified, abandoned_electrified, NULL, NULL, true) AS electrification_state_without_future,
       railway_electrification_label(electrified, deelectrified, construction_electrified, proposed_electrified, voltage, frequency, construction_voltage, construction_frequency, proposed_voltage, proposed_frequency) AS label,
       frequency,
       voltage,
       construction_frequency,
       construction_voltage,
       proposed_frequency,
       proposed_voltage,
       layer
     FROM railway_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'construction', 'preserved')
    ) AS r
  ORDER BY
    layer,
    rank NULLS LAST;

CREATE OR REPLACE VIEW electrification_future AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
      WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
      WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
      WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
      WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
      WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
      WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
      WHEN railway IN ('preserved', 'construction') THEN 400
      ELSE 50
    END AS rank,
    electrification_state,
    railway_voltage_for_state(electrification_state, voltage, construction_voltage, proposed_voltage) AS voltage,
    railway_frequency_for_state(electrification_state, frequency, construction_frequency, proposed_frequency) AS frequency
  FROM
    (SELECT
       way,
       railway,
       usage,
       service,
       construction_railway,
       preserved_railway,
       railway_electrification_state(railway, electrified, deelectrified, abandoned_electrified, construction_electrified, proposed_electrified, false) AS electrification_state,
       frequency,
       voltage,
       construction_frequency,
       construction_voltage,
       proposed_frequency,
       proposed_voltage,
       layer
     FROM railway_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'construction', 'preserved')
    ) AS r
  ORDER BY
    layer,
    rank NULLS LAST;

CREATE OR REPLACE VIEW electrification_signals AS
  SELECT
    way,
    CASE
      {% for feature in electrification_signals.features %}
        -- ({% feature.country %}) {% feature.description %}
        WHEN{% for tag in feature.tags %} "{% tag.tag %}"{% if tag.value %}='{% tag.value %}'{% elif tag.values %} IN ({% for value in tag.values %}{% unless loop.first %}, {% end %}'{% value %}'{% end %}){% end %}{% unless loop.last %} AND{% end %}{% end %}

          THEN {% if feature.icon.match %} CASE
            {% for case in feature.icon.cases %}
            WHEN "{% feature.icon.match %}" ~ '{% case.regex %}' THEN '{% case.value %}'
{% end %}
            ELSE '{% feature.icon.default %}'
          END{% else %} '{% feature.icon.default %}'{% end %}


{% end %}
    END as feature,
    azimuth,
    (signal_direction = 'both') as direction_both
  FROM signals_with_azimuth
  WHERE
    railway = 'signal'
    AND signal_direction IS NOT NULL
    AND "railway:signal:electricity" IS NOT NULL;

--- Gauge ---

CREATE OR REPLACE VIEW gauge_railway_line AS
  SELECT
    way,
    railway,
    usage,
    service,
    CASE
      WHEN railway = 'construction' THEN COALESCE(construction_railway, 'rail')
      WHEN railway = 'preserved' THEN COALESCE(preserved_railway, 'rail')
      ELSE railway
    END as feature,
    CASE
      WHEN railway = 'rail' AND usage IN ('tourism', 'military', 'test') AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service IS NULL THEN 400
      WHEN railway = 'rail' AND usage IS NULL AND service = 'siding' THEN 870
      WHEN railway = 'rail' AND usage IS NULL AND service = 'yard' THEN 860
      WHEN railway = 'rail' AND usage IS NULL AND service = 'spur' THEN 880
      WHEN railway = 'rail' AND usage IS NULL AND service = 'crossover' THEN 300
      WHEN railway = 'rail' AND usage = 'main' AND service IS NULL THEN 1100
      WHEN railway = 'rail' AND usage = 'branch' AND service IS NULL THEN 1000
      WHEN railway = 'rail' AND usage = 'industrial' AND service IS NULL THEN 850
      WHEN railway = 'rail' AND usage = 'industrial' AND service IN ('siding', 'spur', 'yard', 'crossover') THEN 850
      WHEN railway IN ('preserved', 'construction') THEN 400
      ELSE 50
    END AS rank,
    railway_to_int(gauge0) AS gaugeint0,
    gauge0,
    railway_to_int(gauge1) AS gaugeint1,
    gauge1,
    railway_to_int(gauge2) AS gaugeint2,
    gauge2,
    label
  FROM
    (SELECT
       way,
       railway,
       usage,
       service,
       construction_railway,
       preserved_railway,
       railway_desired_value_from_list(1, COALESCE(gauge, construction_gauge)) AS gauge0,
       railway_desired_value_from_list(2, COALESCE(gauge, construction_gauge)) AS gauge1,
       railway_desired_value_from_list(3, COALESCE(gauge, construction_gauge)) AS gauge2,
       railway_gauge_label(gauge) AS label,
       layer
     FROM railway_line
     WHERE railway IN ('rail', 'tram', 'light_rail', 'subway', 'narrow_gauge', 'construction', 'preserved', 'monorail', 'miniature')
    ) AS r
  ORDER BY
    layer,
    rank NULLS LAST;
