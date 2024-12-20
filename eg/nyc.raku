#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*ERR;

my \n = WebService::Nominatim.new;

say n.search('Grand Central Station').first.<name lat lon>;

