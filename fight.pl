#!/usr/bin/env perl

package Student;

use strict;
use warnings;

use Safe;

sub of { 
    my ($class, $style) = @_;
    my $dojo = Safe->new;
    my $art_form = "MartialArt::$style";

    require "MartialArt/$style.pm";

    $dojo->share_from($art_form => [qw(on perform branch merge add change commit)]);

    bless { art_form => $art_form, dojo => $dojo }, $class;
}

sub demonstrate {
    my ($self, $kata) = @_;

    my $steps = do {
        local $/;
        open my ($fh), $kata;
        <$fh>;
    };

    $self->{art_form}->bow_in($kata);
    $self->{dojo}->reval($steps);
    print STDERR $@ if $@;
    $self->{art_form}->bow_out($kata);

}

package main;

use strict;
use warnings;

unshift @ARGV, "dialog" if @ARGV < 2;

Student->of($ARGV[0])->demonstrate($ARGV[1]);
