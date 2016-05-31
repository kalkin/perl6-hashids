use v6;
unit class Hashids;

# An alphabet is a str at least 16 chars long, has no spaces and only has
# unique characters
subset Alphabet of Str where !.comb.repeated and .chars >= 16;
subset Salt of Str where .chars > 0;
subset PositiveInt of Int where * >= 0;

constant $RATIO-SEPARATORS = 3.5;
constant $RATIO-GUARDS = 3.5;

constant $DEFAULT_ALPHABET = ('a'…'z', 'A'…'Z', '1'…'9', '0').join;

has Salt $.salt;
has Alphabet $.alphabet;
has Int $.min-hash-length where * >= 0;
has Str $.separators where !.comb.repeated;

method new(Salt $salt, Alphabet :$alphabet? = $DEFAULT_ALPHABET,
           Int :$min-hash-length? = 0, Str :$separators? = 'cfhistuCFHISTU') {
    my $s = ($alphabet.comb.Bag ∩ $separators.comb.Bag).keys.join;
    $s = consistent-shuffle($s, $salt);
    my $a = "";
    for $alphabet.comb -> $c {
        $a ~= $c unless $separators.index($c);
    }
    say round($a.chars / 12);
    say $salt;
    $a = consistent-shuffle($a, $salt);
    say "===> "~$a.chars;
    return self.bless(:$salt, :alphabet($a), :$min-hash-length, :separators($s));
}

method encode(*@numbers where .all() >= 0) returns Str {
        my $alphabet = consistent-shuffle(self.alphabet, self.salt);
        my $len-alphabet = $alphabet.chars;
        my $len-separators = self.separators.chars;
        my $values-hash =  [+]  @numbers.pairs.map: { .value % (.key + 100) };
        my $encoded = self.alphabet.comb[$values-hash % self.alphabet.chars];
        my $lottery = self.alphabet.comb[$values-hash % self.alphabet.chars];
        for @numbers.kv -> $index, $number {
            say($len-alphabet);
            my $alphabet-salt = ($lottery ~ $!salt ~ $alphabet).comb[$len-alphabet];
            say $alphabet-salt;
            $alphabet = consistent-shuffle($alphabet, $alphabet-salt);
            my $last = self!hash($number, $alphabet);
            $encoded ~= $last;
            my $new-index = (($number % $last[0].ord) + $index) % $len-separators;
            $encoded ~= $!separators.comb[$new-index];
        }
        return $encoded if $encoded.chars >= $!min-hash-length;
        return self!ensure-length($encoded, $alphabet, $values-hash);

}

method !ensure-length(Str $string, Str $alphabet, Int $values-hash) returns Str {
    say $string;
    my $len-separators = $!separators.chars;
    my $index = ($values-hash + $string.comb[0].ord) % $len-separators;
    my $encoded = $!separators.comb[$index] ~ $string;

    if $encoded.chars < $!min-hash-length {
        $index = ($values-hash + $encoded.comb[2].ord) % $len-separators;
        $encoded += $!separators[$index];
    }

    my $split-at = $alphabet.chars / 2;
    while ($encoded.chars < $!min-hash-length) {
    }
    return $encoded;
}

method !hash(PositiveInt $n, Str $alphabet) returns Str {
    my $number = $n;
    my $hashed = '';
    my $alphabet-len = $alphabet.chars;
    loop {
        $hashed = $alphabet.comb[$number % $alphabet-len] ~ $hashed;
        $number = ($number / $alphabet-len).round;
        return $hashed if $number == 0;
    }
}

sub consistent-shuffle(Str $string, Salt $salt) returns Str {
    my Int $length-salt = $salt.chars;
    return $string if $length-salt == 0;
    say "=> $string";

    my Int $index = 0;
    my Int $integer_sum = 0;
    my $str = $string;
    loop (my $i = $string.chars -1; $i >0; $i--){
        $index %= $length-salt;
        my $integer = ord $salt.comb[$index];
        $integer_sum += $integer;
        my $j = ($integer + $index + $integer_sum) % $i;
        my $tmp_char = $str.comb[$j];
        my $trailer = $j+1 < $str.chars ?? $str.comb[$j+1…*].join !! '';
        $str= $str.comb[0…^$j].join ~ $str.comb[$i] ~ $trailer;
        $str = $str.comb[0…^$i].join ~ $tmp_char ~ $str.comb[$i+1…*].join;
        $index++;
    }

    say "→ $str";
    return $str;
    
}

=begin pod

=begin NAME

Hashids — generate short hashes from numbers.

=end NAME

=begin SYNOPSIS

    use Hashids;
    my $hashids = Hashids.new('this is my salt');

    # encrypt a single number
    my $hash = $hashids.encode(123);         # 'YDx'
    my $number = $hashids.decode('Ydx');     # 123

    # or a list
    $hash = $hashids.encode(1, 2, 3);        # 'eGtrS8'
    my @numbers = $hashids.decode('laHquq'); # (1, 2, 3)

=end SYNOPSIS

=begin DESCRIPTION

Hashids is designed for use in URL shortening, tracking stuff, validating
accounts or making pages private (through abstraction.) Instead of showing items
as C<1>, C<2>, or C<3>, you could show them as C<b9iLXiAa>, C<EATedTBy>, and
C<Aaco9cy5>.  Hashes depend on your salt value.

This is a port of the Hashids JavaScript library for Perl 6.

B<IMPORTANT>: This implementation follows the v1.0.0 API release of
hashids.js.
=end DESCRIPTION

=begin AUTHOR

Bahtiar `kalkin-` Gadimov <bahtiar@gadimov.de>

Follow me L<@_kalkin|https://twitter.com/_kalkin>
Or L<https://bahtiar.gadimov.de/>

=end AUTHOR

=begin COPYRIGHT

Copyright 2016 Bahtiar `kalkin-` Gadimov.
=end COPYRIGHT

=begin LICENSE
MIT License. See the LICENSE file. You
can use Hashids in open source projects and commercial products.
=end LICENSE
=end pod
