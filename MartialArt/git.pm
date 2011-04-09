package MartialArt::git;

use strict;
use warnings;

use File::Temp;

my @commands;

my $floor;
my $branch;

sub git {
    print "===> git ", join(" ", @_), "\n";
    system("git", @_) == 0 or die "Error executing git: $?";
}

sub bow_in {
    my ($class, $kata) = @_;

    $floor = File::Temp->newdir;
    chdir $floor->dirname;
    git "init";
    $branch = "master";
}

sub bow_out {
    my ($class, $kata) = @_;
    $floor = undef;
}

sub on {
    my ($branch_name, $actions) = @_;

    git "checkout", $branch_name if $branch ne $branch_name;
    $branch = $branch_name;
    $_->() for (@$actions);
}

sub perform(&) {
    @commands = ();
    shift->();
    return [@commands];
}

sub branch {
    my ($from, $to) = @_;

    git "branch", $to, $from;
}

sub merge {
    my ($from, $to) = @_;

    git "checkout", $to if $branch ne $to;
    $branch = $to;

    git "merge", $from;
}

sub add {
    my ($file, $contents) = @_;

    push @commands, sub { 
        open my ($target), "> $file";
        print $target $contents;
        close $target;

        git "add", $file;
    }
}

sub change {
    my ($file, $new_contents) = @_;

    add($file, $new_contents);
}

sub commit {
    my ($msg) = @_;

    push @commands, sub { git "commit", "-a", "-m", $msg }
}

1;
