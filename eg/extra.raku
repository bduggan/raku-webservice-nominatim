#!raku

use WebService::Nominatim;
use Log::Async;

logger.send-to: $*ERR;

my \n = WebService::Nominatim.new;

say n.search('Eiffel Tower', limit => 1, :extratags);
say n.search('Eiffel Tower', limit => 1, accept-language => 'fr')[0]<name>;
say n.search('Eiffel Tower', limit => 1, accept-language => 'en-US')[0]<name>;
