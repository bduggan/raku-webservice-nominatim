use WebService::Nominatim;

my \n = WebService::Nominatim.new;

say n.search('Grand Place, Brussels',:format<geojson>,:raw);


