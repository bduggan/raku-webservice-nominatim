#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*ERR;

my \n = WebService::Nominatim.new;

say n.search: 'Main St', :limit(5);
pd n.search('Grand Central Station, New York, NY');
pd n.search(query => 'Grand Central Station, New York, NY');

