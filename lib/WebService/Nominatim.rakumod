#!raku

unit class WebService::Nominatim;

use HTTP::Tiny;
use URI::Encode;
use Log::Async;
use JSON::Fast;

logger.untapped-ok = True;

has $.url = 'https://nominatim.openstreetmap.org';
has $.ua = HTTP::Tiny.new(agent => 'Raku WebService::Nominatim');
has $.email;
has $.debug;
has $.dedupe;

subset Formats of Str where <xml json jsonv2 geojson geocodejson>.any;
subset Layers of Str where <address poi railway natural manmade>.any;
subset FeatureTypes of Str where <country state city settlement>.any;

sub mkv($value) {
  return '' unless defined $value;
  return $value.Int if $value ~~ Bool;
  return $value.join(',') if $value ~~ Array;
  return $value;
}

method get($path, :%query, Bool :$parse-json = True) {
  %query<email> = $_ with $.email;
  %query<dedupe> = $_ with $.dedupe;
  %query<debug> = $_ with $.debug;

  my $url = uri_encode(
    $.url
    ~ $path
    ~ '?'
    ~ %query.map({
      defined(.value)
      ?? ( .key ~ '=' ~ mkv(.value) )
      !! Empty
    }).join('&') );

  trace "GET $url";

  my $response = $.ua.get($url);

  if $response<status> != 200 {
    fail "Request failed: $response<status> $response<reason>";
  }

  my $res = $response<content>.decode;
  return $res unless $parse-json;
  my $json = try from-json($res);
  return $json if $json;
  return $res;
}

multi method search(:$query,|c) {
  self.search($query, |c);
}

multi method search($query,
     Formats :$format = 'jsonv2',
     :$layer,
     :$featureType,
     Bool :$addressdetails,
     Int :$limit = 1,
     Bool :$extratags,
     Bool :$namedetails,
     :$accept-language,
     :$countrycodes,
     :$exclude_place_ids,
     :$viewbox, Bool :$bounded,
     Bool :$polygon_geojson, Bool :$polygon_kml, Bool :$polygon_svg, Bool :$polygon_text,
    :$polygon_threshold,
     Bool :$raw = False) {

    my %query = ( :$format,
        :$layer,
        :$addressdetails,
        :$limit,
        :$extratags,
        :$namedetails,
        :$accept-language,
        :$countrycodes,
        :$featureType,
        :$exclude_place_ids,
        :$viewbox, :$bounded,
        :$polygon_geojson, :$polygon_kml, :$polygon_svg, :$polygon_text,
        :$polygon_threshold,
    );

    given $query {
      when Str {
        %query<q> = $query;
      }
      when Hash {
        if $query.keys ⊈ <amenity street city county state country postalcode> {
          warning "some query parameters not recognized: { $query.keys.join(', ') }";
        }
        %query.push: $query.kv;
      }
    }
    my $parse-json = !$raw && (!$format || $format.contains('json'));
    self.get('/search', :%query, :$parse-json );
}

=begin pod

=head1 NAME

WebService::Nominatim - Client for the OpenStreetMap Nominatim API

=head1 SYNOPSIS

  use WebService::Nominatim;

  my \n = WebService::Nominatim.new;

  say n.search('Grand Central Station').first.<name lat lon>;
  # (Grand Central Terminal 40.75269435 -73.97725295036929)

  my $geo = n.search: '221B Baker Street, London, UK';
  my $geo = n.search: query => '221B Baker Street, London, UK';
  my $geo = n.search: query => { street => '221B Baker Street', city => 'London', country => 'UK' };
  say $geo.head.<lat lon>;
  # (51.5233879 -0.1582367)

  say n.search: 'Grand Place, Brussels', :format<geojson>, :raw;
  {"type":"FeatureCollection", ... 

=head1 DESCRIPTION

This is an interface to OpenStreetMap's Nominatim Geocoding API, L<https://nominatim.org|https://nominatim.org>.

=head1 ATTRIBUTES

=head2 url

The base URL for the Nominatim API. Defaults to C<https://nominatim.openstreetmap.org>.

=head2 email

The email address to use in the C<email> query parameter. Optional, but recommended if you are
sending a lot of requests.

=head2 debug

Optionally send send debug => 1 in search requests.  Responses will be HTML.

=head2 dedupe

Optionally send dedupe => 1 to search request.

=head1 METHODS

=head2 search

Search for a location using either a string search or a structured search. 

=head3 Usage

  $n.search('Grand Central Station');
  $n.search: 'Main St', :limit(5);
  $n.search: '221B Baker Street, London, UK';
  $n.search: query => '221B Baker Street, London, UK';
  $n.search: query => { street => '221B Baker Street', city => 'London', country => 'UK' }, limit => 5;

=head3 Parameters

See L<https://nominatim.org/release-docs/develop/api/Search/> for details about meanings of the parameters.

=item C<$query>

  The search query. This can be a string or a hash of search parameters.
  It can be a named parameter, or the first positional parameter.

=item C<:raw>

  If set to a true value, the raw response will be returned as a string, without JSON parsing.

=item C<:format>

  The format of the response. Defaults to C<jsonv2>.

Other parameters are passed through to the API as query parameters:

  :$layer,
  :$featureType,
  Bool :$addressdetails,
  Int :$limit = 1,
  Bool :$extratags,
  Bool :$namedetails,
  :$accept-language,
  :$countrycodes,
  :$exclude_place_ids,
  :$viewbox, Bool :$bounded,
  Bool :$polygon_geojson, Bool :$polygon_kml, Bool :$polygon_svg, Bool :$polygon_text,
  :$polygon_threshold

=head1 SEE ALSO

L<https://nominatim.org/release-docs/develop/api/Search/>

=head1 AUTHOR

Brian Duggan

=end pod
