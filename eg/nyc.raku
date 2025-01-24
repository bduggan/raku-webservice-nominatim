#!raku

use WebService::Nominatim 'n', '-debug';

say n.search('Grand Central Station').first.<name lat lon>;

