#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*OUT;

my \n = WebService::Nominatim.new;
say n.search: 'Grand Place, Brussels', :format<geojson>, :raw;
