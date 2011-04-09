package MartialArt::git;

use strict;
use warnings;

use File::Temp;
use IO::File;

my @commands;

my $floor;

sub git {
    system("git", @_) == 0 or die "Error executing git: $?";
}

sub bow_in {
    my ($class, $kata) = @_;

    $floor = File::Temp->newdir;
    chdir $floor->dirname;
    git "init";
}

sub bow_out {
    my ($class, $kata) = @_;
    $floor = undef;
}

sub on {
    my ($branch_name, $actions) = @_;

    git "checkout", $branch_name;
    $_->() for (@$actions);
}

sub perform(&) {
    @commands = ();
    shift->();
    return [@commands];
}

sub branch {
    my ($from, $to) = @_;

    git "checkout", $from;
    git "branch", $to;
}

sub merge {
    my ($from, $to) = @_;

    git "checkout", $to;
    git "merge", $from;
}

sub add {
    my ($file, $contents) = @_;

    push @commands, sub { 
        my $target = IO::File->new("> $file");
        print $target $contents;
        $target->close();

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
