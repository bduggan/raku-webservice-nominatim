use WebService::Nominatim 'n';

say n.lookup('R1316770', :format<geojson>);
say n.lookup(relation-id => '1316770', :format<geojson>);
say n.lookup(relation-ids => [ 1316770, ], :format<geojson>, :polygon_geojson);


