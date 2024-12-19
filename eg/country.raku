#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*OUT;

my \n = WebService::Nominatim.new;
pd n.search('Grand Place, Brussels',countrycodes => <GB>);
pd n.search('Grand Place, Brussels',countrycodes => <GB BE>);


