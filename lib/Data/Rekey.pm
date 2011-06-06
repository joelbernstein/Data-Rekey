package Data::Rekey;
use defaults;
use Data::Clone;
use Carp ();

sub key {
    my ($what, @keys) = @_;
    Carp::croak("First argument must be an arrayref of hashrefs")
        unless ref $what eq 'ARRAY';
    my $out = {};
    _inner_key($what, $out, shift @keys);

    for my $key (@keys) {
        warn "key $key";
        for (keys %$out) {
            use DDS; warn "key $key, skey $_, out " => Dump($out);
            my $new = delete $out->{$_};
            warn "new " => Dump($new);
            my $newout = $out->{$_} = {};
#            if (exists $new->{$key}) {
#                _inner_key($new, $newout, $key);
#            } else {
                for (ref $new eq 'ARRAY' ? @$new : $new) {
                    while (my ($k, $v) = each %$_) {
                        my $newnewout = $newout->{$k} = {};
                        if (ref $v eq 'ARRAY') {
                            _inner_key($_, $newnewout, $key) for @$v;
                        } else {
                            push @{ $newnewout->{$v} //= [] }, {};
                        }
                    }
                }
            }
#        }
        warn "done key $key - out " => Dump($out);
    }
    $out;
}


sub _inner_key {
    my ($in, $out, $key) = @_;
    warn "in/out/key:\n" => Dump(\@_);
    for my $hashref (map { clone($_) } ref $in eq 'ARRAY' ? @$in : $in) {
        Carp::croak("Required key '$key' does not exist in hashref --\n", Dump($hashref))
            unless exists $hashref->{$key};
        my $value = delete $hashref->{$key};
        $out->{$value} //= [];
        push @{ $out->{$value} }, $hashref;
    }
    $out;
}
