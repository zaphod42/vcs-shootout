package MartialArt::dialog;

use strict;
use warnings;

my @commands;

sub bow_in {
    my ($class, $kata) = @_;
    print "Prepare for $kata\n\n";
}

sub bow_out {
    my ($class, $kata) = @_;
    print "Finished with $kata\n\n";
}

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

sub branch {
    my ($from, $to) = @_;

    print "branch $from to $to\n";
}

sub merge {
    my ($from, $to) = @_;

    print "merge $from into $to\n";
}

sub add {
    my ($file, $contents) = @_;

    push @commands, sub { print "add file named <$file> containing <$contents>\n" }
}

sub change {
    my ($file, $new_contents) = @_;

    push @commands, sub { print "change file named <$file> to contain <$new_contents>\n" }
}

sub move {
    my ($file, $new_name) = @_;

    push @commands, sub { print "move file named <$file> to <$new_name>\n" }
}

sub commit {
    my ($msg) = @_;

    push @commands, sub { print "commit with message <$msg>\n" }
}

1;
