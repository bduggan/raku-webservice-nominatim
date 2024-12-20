#!/usr/bin/env raku

use WebService::Nominatim;

my \n = WebService::Nominatim.new;

#say n.search: '221B Baker Street, London, UK';
#say n.search: query => '221B Baker Street, London, UK';
my $geo = n.search: query => { street => '221B Baker Street', city => 'London', country => 'UK' };
say $geo.head.<lat lon>;

#say n.search: 'Grand Place, Brussels, Belgium';
#say n.search: 'Grand Place, Brussels', :format<geojson>, :raw;

