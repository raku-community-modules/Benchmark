my subset PIntD of Int where * > 0;

my proto sub timethis(|) is export {*}
my multi sub timethis(PIntD $count, Str:D $code, Bool :$statistics) {
    use MONKEY-SEE-NO-EVAL;
    timethis $count, { EVAL $code }, :$statistics
}

my multi sub timethis(PIntD $count, &code, Bool :$statistics! where *.so --> Hash:D[Duration:D]) { 

    my @exec-times = gather 
      for ^$count {
          LEAVE take now - ENTER now;
          code()
      };

    @exec-times = @exec-times.sort;

    my $min = @exec-times.head;
    my $max = @exec-times.tail;

    my $mid = $count div 2;
    my $median = Duration.new: $count %% 2 ?? @exec-times[($mid - 1),$mid].sum / 2 !! @exec-times[$mid];    
    my $mean = Duration.new: @exec-times.sum / $count;
    my $sd = Duration.new: sqrt( @exec-times.map( { ($_ - $mean)**2 } ).sum / $count);

    my Duration %result = :$mean, :$median, :$min, :$max, :$sd;
    return %result;
}

my multi sub timethis(PIntD $count, &code, Bool :$statistics) { 
    my $start-time := time;
    code() for ^$count;
    my $end-time   := time;
    my $difference := $end-time - $start-time;
    ($start-time, $end-time, $difference, $difference / $count)
}

my proto sub timethese(|) is export {*}
my multi timethese(PIntD $count, %h, Bool :$statistics! where *.so) {
    Map.new: (%h.map: { .key => timethis($count, .value, :statistics) })
}

my multi timethese(PIntD $count, %h, Bool :$statistics) {
    Map.new: (%h.map: { .key => timethis($count, .value) })
}

=begin pod

=head1 NAME

Benchmark - Simple benchmarking

=head1 SYNOPSIS

=begin code :lang<raku>

use Benchmark;

my ($start, $end, $diff, $avg) = timethis(1000, "code");
my @stats = timethis(1000, sub { #`( code ) });
say @stats;

my %results = timethese 1000, {
    "foo" => sub { ... },
    "bar" => sub { ... },
};
say ~%results;

=end code

=head1 DESCRIPTION

A simple benchmarking module with an interface similar to Perl's
C<Benchmark.pm>.  However, rather than output results to C<$*OUT>,
the results are merely returned so that you can output them however
you please.

You can also have some basic statistics:

=begin code :lang<raku>

use Benchmark;

%result = timethis(10, { sleep rand }, :statistics);
say %result;
say "$_ : %result{$_}" for <min median mean max sd>;

my %results = timethese 5, {
    "foo" => { sleep rand },
    "bar" => { sleep rand },
}, :statistics;
say ~%results;

=end code

=head1 AUTHOR

Jonathan Scott Duff

=head1 COPYRIGHT AND LICENSE

Copyright 2009 - 2016 Jonathan Scott Duff

Copyright 2017 - 2023 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
