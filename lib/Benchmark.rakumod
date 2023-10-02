my proto sub timethis(|) is export {*}
my multi sub timethis(UInt $count, Str:D $code) {
    use MONKEY-SEE-NO-EVAL;
    timethis $count, { EVAL $code }
}

my multi sub timethis(UInt $count, &code) { 
    my $start-time := time;

    my @exec-times = gather 
      for ^$count {
          LEAVE take now - ENTER now; 
          code()
      };

    my $end-time   := time;
    my $difference := $end-time - $start-time;

    my $mean = @exec-times.sum / $count;
    my $sd = sqrt( @exec-times.map( { ($_ - $mean)**2 } ).sum / $count);
    my $min = @exec-times.min;
    my $max= @exec-times.max;

    ($start-time, $end-time, $difference, $difference / $count, $min, $mean, $max, $sd)
}

my sub timethese(UInt $count, %h) is export {
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
}
say ~%results;

=end code

=head1 DESCRIPTION

A simple benchmarking module with an interface similar to Perl's
C<Benchmark.pm>.  However, rather than output results to C<$*OUT>,
the results are merely returned so that you can output them however
you please.

=begin code :lang<raku>

use Benchmark;

my ($start, $end, $diff, $avg, $min, $mean, $max, $sd) = timethis(10, { sleep rand });
say ($start, $end, $diff, $avg, $min, $mean, $max, $sd);

=end code

=head1 AUTHOR

Jonathan Scott Duff

=head1 COPYRIGHT AND LICENSE

Copyright 2009 - 2016 Jonathan Scott Duff

Copyright 2017 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
