[![Actions Status](https://github.com/raku-community-modules/Benchmark/workflows/test/badge.svg)](https://github.com/raku-community-modules/Benchmark/actions)

NAME
====

Benchmark - Simple benchmarking

SYNOPSIS
========

```raku
use Benchmark;

my ($start, $end, $diff, $avg) = timethis(1000, "code");
my @stats = timethis(1000, sub { #`( code ) });
say @stats;

my %results = timethese 1000, {
    "foo" => sub { ... },
    "bar" => sub { ... },
}
say ~%results;
```

DESCRIPTION
===========

A simple benchmarking module with an interface similar to Perl's `Benchmark.pm`. However, rather than output results to `$*OUT`, the results are merely returned so that you can output them however you please.

AUTHOR
======

Jonathan Scott Duff

COPYRIGHT AND LICENSE
=====================

Copyright 2009 - 2016 Jonathan Scott Duff

Copyright 2017 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

