[![Actions Status](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-webservice-nominatim/actions/workflows/macos.yml)

NAME
====

WebService::Nominatim - Raku client for the OpenStreetMap Nominatim API

SYNOPSIS
========

    use WebService::Nominatim;

    my \n = WebService::Nominatim.new;

    say n.search(query => 'Grand Central Station', :addressdetails).head.<address><road city state>.join(', ');
    # East 42nd Street, City of New York, New York

    say n.search: 'Grand Central Station';

    say n.search: 'Main St', :limit(5);

    say n.search: '221B Baker Street, London, UK';
    say n.search: query => '221B Baker Street, London, UK';
    say n.search: query => { street => '221B Baker Street', city => 'London', country => 'UK' };

    say n.search: 'Grand Place, Brussels, Belgium';
    say n.search('Grand Place, Brussels',:format<geojson>,:raw);

DESCRIPTION
===========

This is an interface to OpenStreetMap's Nominatim Geocoding API, [https://nominatim.org](https://nominatim.org).

ATTRIBUTES
==========

url
---

The base URL for the Nominatim API. Defaults to `https://nominatim.openstreetmap.org`.

ua
--

The [HTTP::Tiny](https://raku.land/zef:jjatria/HTTP::Tiny) user agent object. Defaults to a new instance of `HTTP::Tiny` with the agent string set to `Raku WebService::Nominatim`.

email
-----

The email address to use in the `email` query parameter. This is optional, but recommended if you are sending a lot of requests.

debug
-----

If set to a true value, the `debug` query parameter will be set to `1` in all requests. In this case, the response will be HTML (not JSON).

dedupe
------

If set to a true value, the `dedupe` query parameter will be set to `1` in search requests.

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

SEE ALSO
========

[https://nominatim.org/release-docs/develop/api/Search/](https://nominatim.org/release-docs/develop/api/Search/)

AUTHOR
======

Brian Duggan

