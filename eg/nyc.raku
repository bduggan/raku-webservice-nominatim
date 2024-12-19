#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*ERR;

my \n = WebService::Nominatim.new;

say n.search: 'Main St', :limit(5);
say n.search('Grand Central Station, New York, NY');
say n.search(query => 'Grand Central Station', :addressdetails).head.<address><road city state>.join(', ');

