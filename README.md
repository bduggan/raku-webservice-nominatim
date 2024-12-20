[![Actions Status](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/macos.yml)

NAME
====

WebService::Nominatim - Client for the OpenStreetMap Nominatim Geocoding API

SYNOPSIS
========

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
```geojson
{"type":"FeatureCollection","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright","features":[{"type":"Feature","properties":{"place_id":97663568,"osm_type":"way","osm_id":991425177,"place_rank":25,"category":"boundary","type":"protected_area","importance":0.4874302285645721,"addresstype":"protected_area","name":"Grand-Place - Grote Markt","display_name":"Grand-Place - Grote Markt, Quartier du Centre - Centrumwijk, Pentagone - Vijfhoek, Bruxelles - Brussel, Brussel-Hoofdstad - Bruxelles-Capitale, Région de Bruxelles-Capitale - Brussels Hoofdstedelijk Gewest, 1000, België / Belgique / Belgien"},"bbox":[4.3512177,50.8460246,4.3537194,50.8474356],"geometry":{"type": "Point","coordinates": [4.352408060161565, 50.84672905]}}]}
```

DESCRIPTION
===========

This is an interface to OpenStreetMap's Nominatim Geocoding API, [https://nominatim.org](https://nominatim.org).

ATTRIBUTES
==========

url
---

The base URL for the Nominatim API. Defaults to `https://nominatim.openstreetmap.org`.

email
-----

The email address to use in the `email` query parameter. Optional, but recommended if you are sending a lot of requests.

debug
-----

Optionally send debug => 1 in search requests. Responses will be HTML.

dedupe
------

Optionally send dedupe => 1 to search request.

METHODS
=======

search
------

Search for a location using either a string search or a structured search. 

### Usage

    $n.search('Grand Central Station');
    $n.search: 'Main St', :limit(5);
    $n.search: '221B Baker Street, London, UK';
    $n.search: query => '221B Baker Street, London, UK';
    $n.search: query => { street => '221B Baker Street', city => 'London', country => 'UK' }, limit => 5;

### Parameters

See [https://nominatim.org/release-docs/develop/api/Search/](https://nominatim.org/release-docs/develop/api/Search/) for details about meanings of the parameters.

  * `$query`

    The search query. This can be a string or a hash of search parameters.
    It can be a named parameter, or the first positional parameter.

  * `:raw`

    If set to a true value, the raw response will be returned as a string, without JSON parsing.

  * `:format`

    The format of the response. Defaults to jsonv2.  Other options are xml, json, geojson, and geocodejson.

Other parameters -- see [https://nominatim.org/release-docs/develop/api/Search/](https://nominatim.org/release-docs/develop/api/Search/)

  * `:layer`

  * `:featureType`

  * `:addressdetails`

  * `:limit`

  * `:extratags`

  * `namedetails`

  * `:accept-language`

  * `:countrycodes`

  * `:exclude_place_ids`

  * `:viewbox`

  * `:bounded`

  * `:polygon_geojson`

  * `:polygon_kml`

  * `:polygon_svg`

  * `:polygon_text`

  * `:polygon_threshold`

SEE ALSO
========

[https://nominatim.org/release-docs/develop/api/Search/](https://nominatim.org/release-docs/develop/api/Search/)

AUTHOR
======

Brian Duggan

