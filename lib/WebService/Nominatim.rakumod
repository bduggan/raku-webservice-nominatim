#!raku

class WebService::Nominatim {

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
has $.logger = logger;

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
    fail "Request failed: $response<status> $response<reason> " ~ $response<content>.decode;
  }

  my $res = $response<content>.decode;
  return $res unless $parse-json;
  my $json = try from-json($res);
  return $json if $json;
  return $res;
}

multi method search(:$query,|c --> List) {
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
     Bool :$raw = False --> List) {

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
    my $got = self.get('/search', :%query, :$parse-json );
    return $got.list if $got ~~ List;
    return [ $got ];
}

multi method lookup(
  :@node-ids,
  :@way-ids,
  :@relation-ids,
  :$node-id,
  :$way-id,
  :$relation-id,
  :$format,
  Bool :$addressdetails,
  Bool :$extratags,
  Bool :$accept-language,
  Bool :$polygon_geojson,
  Bool :$polygon_kml,
  Bool :$polygon_svg,
  Bool :$polygon_text,
  :$polygon_threshold,

  Bool :$raw = False --> List) {
  my @ids =  |( @node-ids.map: { "N" ~ $_ } ),
             |( @way-ids.map: { "W" ~ $_ } ),
             |( @relation-ids.map: { "R" ~ $_ } );
  @ids.push: "N$node-id" if $node-id;
  @ids.push: "W$way-id" if $way-id;
  @ids.push: "R$relation-id" if $relation-id;
  self.lookup(@ids.join(','),
  :$format,
  :$raw, :$addressdetails, :$extratags, :$accept-language,
  :$polygon_geojson, :$polygon_kml, :$polygon_svg, :$polygon_text,
  :$polygon_threshold);
}


multi method lookup($osm_ids,
  :$format,
  Bool :$raw = False,
  Bool :$addressdetails,
  Bool :$extratags,
  Bool :$accept-language,
  Bool :$polygon_geojson,
  Bool :$polygon_kml,
  Bool :$polygon_svg,
  Bool :$polygon_text,
  :$polygon_threshold
  --> List) {
  my $parse-json = !$raw && (!$format || $format.contains('json'));
  my %query = (
    :$osm_ids,
    :$format
    :$addressdetails,
    :$extratags,
    :$accept-language,
    :$polygon_geojson,
    :$polygon_kml,
    :$polygon_svg,
    :$polygon_text,
    :$polygon_threshold
  );

  my $got = self.get("/lookup", :%query, :$parse-json);

  return $got.list if $got ~~ List;
  return [ $got ];
}

method status {
  my $got = self.get('/status', query => %( :format<json> ), :parse-json);
  return $got;
}

=begin pod

=head1 NAME

WebService::Nominatim - Client for the OpenStreetMap Nominatim Geocoding API

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

```geojson

{"type":"FeatureCollection","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright","features":[{"type":"Feature","properties":{"place_id":97663568,"osm_type":"way","osm_id":991425177,"place_rank":25,"category":"boundary","type":"protected_area","importance":0.4874302285645721,"addresstype":"protected_area","name":"Grand-Place - Grote Markt","display_name":"Grand-Place - Grote Markt, Quartier du Centre - Centrumwijk, Pentagone - Vijfhoek, Bruxelles - Brussel, Brussel-Hoofdstad - Bruxelles-Capitale, Région de Bruxelles-Capitale - Brussels Hoofdstedelijk Gewest, 1000, België / Belgique / Belgien"},"bbox":[4.3512177,50.8460246,4.3537194,50.8474356],"geometry":{"type": "Point","coordinates": [4.352408060161565, 50.84672905]}}]}

```

=head1 DESCRIPTION

This is an interface to OpenStreetMap's Nominatim Geocoding API, L<https://nominatim.org|https://nominatim.org>.

=head1 EXPORTS

  use WebService::Nominatim;
  my \n = WebService::Nominatim.new;

Equivalent to:

  use WebService::Nominatim 'n';

Add debug output:

  use WebService::Nominatim 'n' '-debug';

If an argument is provided, a new instance will be returned.
If C<-debug> is provided, the instance will send logs to stderr.
Note this is different from the C<debug> attribute, which gets debug
information from the server.

=head1 ATTRIBUTES

=head2 url

The base URL for the Nominatim API. Defaults to C<https://nominatim.openstreetmap.org>.

=head2 email

The email address to use in the C<email> query parameter. Optional, but recommended if you are
sending a lot of requests.

=head2 debug

Optionally send debug => 1 in search requests.  Responses will be HTML.

=head2 dedupe

Optionally send dedupe => 1 to search request.

=head1 EXPORTS

If an argument is given to the module, it is assumed to be a name
and the module creates a new C<WebService::Nominatim> object.
Also "-debug" will send debug output to stderr.  These are equivalent:

  use WebService::Nominatim 'nom', '-debug';

and

  use WebService::Nominatim;;
  my \nom = WebService::Nominatim.new;
  nom.logger.send-to: $*ERR;

=head1 METHODS

=head2 search

Search for a location using either a string search or a structured search. 
This will always return a list.  The items in the list may be strings or hashes,
depending on the format (json formats will be parsed into hashes).  Use C<:raw>
to return strings.

=head3 Usage

  $n.search('Grand Central Station');
  say .<display_name> for $n.search: 'Main St', :limit(5);
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

  The format of the response. Defaults to jsonv2.  Other options are xml, json, geojson, and geocodejson.

Other parameters:

=item C<:layer>

=item C<:featureType>

=item C<:addressdetails>

=item C<:limit>

=item C<:extratags>

=item C<:namedetails>

=item C<:accept-language>

=item C<:countrycodes>

=item C<:exclude_place_ids>

=item C<:viewbox>

=item C<:bounded>

=item C<:polygon_geojson>

=item C<:polygon_kml>

=item C<:polygon_svg>

=item C<:polygon_text>

=item C<:polygon_threshold>

=head2 lookup

Look up an object.

  say n.lookup('R1316770', :format<geojson>);
  say n.lookup(relation-id => '1316770', :format<geojson>);
  say n.lookup(relation-ids => [ 1316770, ], :format<geojson>, :polygon_geojson);

=head3 Parameters

Many of the same parameters as C<search> are available.

Additionally, C<node-ids>, C<way-ids>, and C<relation-ids> can be used to look up multiple objects.
And C<node-id>, C<way-id>, and C<relation-id> can be used to look up a single object.

See L<https://nominatim.org/release-docs/develop/api/Lookup/> for more details.

=head2 status

Get the status of the Nominatim server.

  say n.status;

=head1 SEE ALSO

L<https://nominatim.org/release-docs/develop/api/Search/>

=head1 AUTHOR

Brian Duggan

=end pod

}

sub EXPORT($name = Nil, *@args) {
  return %( ) without $name;
  my $obj = WebService::Nominatim.new;
  $obj.logger.send-to: $*ERR if @args.first: * eq '-debug';
  %( $name => $obj );
}
