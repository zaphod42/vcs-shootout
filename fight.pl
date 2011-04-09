#!/usr/bin/env perl

package MartialArt::dialog;

use strict;
use warnings;

my @commands;

sub on {
    my ($branch_name, $actions) = @_;

    print "on $branch_name\n";
    print "\t" and $_->() for (@$actions);
}

sub perform(&) {
    @commands = ();
    shift->();
    return [@commands];
}

sub branch($$) {
    my ($from, $to) = @_;

    print "branch $from to $to\n";
}

sub merge($$) {
    my ($from, $to) = @_;

    print "merge $from into $to\n";
}

sub add($$) {
    my ($file, $contents) = @_;

    push @commands, sub { print "add file named <$file> containing <$contents>\n" }
}

sub change($$) {
    my ($file, $new_contents) = @_;

    push @commands, sub { print "change file named <$file> to contain <$new_contents>\n" }
}

sub commit($) {
    my ($msg) = @_;

    push @commands, sub { print "commit with message <$msg>\n" }
}

package Student;

use strict;
use warnings;

use Safe;

sub of { 
    my ($class, $style) = @_;
    my $safe = Safe->new;

    $safe->share_from("MartialArt::$style" => [qw(on perform branch merge add change commit)]);

    return bless { dojo => $safe }, $class;
}

sub demonstrate {
    my ($self, $kata) = @_;

    $self->{dojo}->rdo($kata);

    print $@ if $@;
}

package main;

use strict;
use warnings;

Student->of('dialog')->demonstrate("one-file-same-change.vs");
