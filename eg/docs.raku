#!/usr/bin/env raku

use WebService::Nominatim;

  use WebService::Nominatim;

  my $nominatim = WebService::Nominatim.new;

  say $nominatim.search: 'Grand Central Station, New York, NY';
  say $nominatim.search: 'Grand Central Station', :limit(5), :format<json>;
  say $nominatim.search: 'Grand Central Station', :limit(5), :format<json>, :addressdetails;




