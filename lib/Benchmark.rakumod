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

    my Duration:D %result = :$mean, :$median, :$min, :$max, :$sd;
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

# vim: expandtab shiftwidth=4
