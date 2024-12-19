#!raku

use WebService::Nominatim;
use Log::Async;
use PrettyDump;

logger.send-to: $*OUT;

my \n = WebService::Nominatim.new;
pd n.search('Grand Place, Brussels',:addressdetails);
pd n.search('Grand Place, Brussels', format => 'geocodejson', :raw);
pd n.search('Grand Place, Brussels',:!addressdetails);

pd n.search(query => {
  street => 'Rue Victor Hugo', city => 'Brussels', country => 'Belgium'
}, accept-language => 'en', :addressdetails);

pd n.search(query => { street => 'Rue Victor Hugo', city => 'Brussels', country => 'Belgium' }, :addressdetails);

