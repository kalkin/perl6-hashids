use v6;
use Test;
use Hashids;

constant $SALT = 'this is my salt';
constant $DEFAULT_ALPHABET = ('a'…'z', 'A'…'Z', '1'…'9', '0').join;
constant $DEFAULT_SEPARATORS = <cfhistuCFHISTU>;


plan 10;
subtest {
    plan 5;
    is Hashids::consistent-shuffle('123', 'salt'), '231';
    is Hashids::consistent-shuffle(('a'…'j').join, 'salt'), 'iajecbhdgf';
    is Hashids::consistent-shuffle(('a'…'z', 'A'…'Z').join, $SALT), <fAYtoVWnhcFKXqxmlPHijDUZrygwNLSbkasGQJvuBTIepdRMEOzC>;
    is Hashids::consistent-shuffle($DEFAULT_SEPARATORS, $SALT), <UHuhtcITCsFifS>;
    is Hashids::consistent-shuffle(<abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890>, $SALT), <AdG05N6y2rljDQak4xgzn8ZR1oKYLmJpEbVq3OBv9WwXPMe7>;
}, 'internal consistent-shuffle function';

is Hashids::remove-str($DEFAULT_ALPHABET, $DEFAULT_SEPARATORS), <abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890>;

my $h = Hashids.new($SALT);

is $h.min-hash-length, 0, 'hash length';

subtest {
    plan 4;
    is Hashids::hash(23, ('a'…'z').join), 'x';
    is Hashids::hash(4, ('0'…'9').join), '4';
    is Hashids::hash(4, 'qwer243rc23'), '2';
    is Hashids::hash(12, 'qwer243rc23'), 'ww';
}, 'internal hash function';

is $h.salt, $SALT;
is $h.separators, <UHuhtcITCsFifS>, 'Shuffled separators';
is $h.alphabet, <5N6y2rljDQak4xgzn8ZR1oKYLmJpEbVq3OBv9WwXPMe7>, 'Prepared alphabet';

is $h.guards, <AdG0>;

subtest {
    plan 3;
    is $h.encode(123), <YDx>;
    is $h.encode(12345), <NkK9>;
    is $h.encode(1, 2, 3), 'eGtrS8';
}, "encode function";

subtest {
    plan 3;
    is $h.decode(<YDx>), 123;
    is $h.decode(<NkK9>), 12345;
    is $h.decode('eGtrS8'), (1,2,3);
}, "decode function";

done-testing;
