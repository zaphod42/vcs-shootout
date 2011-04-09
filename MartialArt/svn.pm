package MartialArt::svn;

use strict;
use warnings;

use File::Temp;
use File::Path qw(make_path);

my @commands;

my $armory;
my $floor;

my $opponent;

sub svn {
    print "===> svn ", join(" ", @_), "\n";
    system("svn", @_) == 0 or die "Error executing svn: $?";
}

sub svnadmin {
    print "===> svnadmin ", join(" ", @_), "\n";
    system("svnadmin", @_) == 0 or die "Error executing svnadmin: $?";
}

sub location { "file://$armory/" . shift }

sub bow_in {
    my ($class, $kata) = @_;

    $floor = File::Temp->newdir;
    $armory = $floor->dirname . "/repo";
    $opponent = "master";

    make_path($armory, $floor->dirname . "/floor");
    chdir $floor->dirname . "/floor";
    svnadmin "create", $armory;
    svn "mkdir", location($opponent), "-m", "creating $opponent branch";
    svn "co", location($opponent), ".";
}

sub bow_out {
    my ($class, $kata) = @_;
    $floor = undef;
}

sub on {
    my ($opponent_name, $actions) = @_;

    svn "switch", location($opponent_name) if $opponent ne $opponent_name;
    $opponent = $opponent_name;
    $_->() for (@$actions);
}

sub perform(&) {
    @commands = ();
    shift->();
    return [@commands];
}

sub branch {
    my ($from, $to) = @_;

    svn "cp", location($from), location($to), "-m", "branch $from to $to";
}

sub merge {
    my ($from, $to) = @_;

    svn "switch", location($to) if $opponent ne $to;
    $opponent = $to;

    svn "merge", "--accept", "postpone", location($from), ".";
}

sub add {
    my ($file, $contents) = @_;

    push @commands, sub { 
        open my ($target), "> $file";
        print $target $contents;
        close $target;

        svn "add", $file;
    }
}

sub change {
    my ($file, $new_contents) = @_;

    push @commands, sub { 
        open my ($target), "> $file";
        print $target $new_contents;
        close $target;
    }
}

sub commit {
    my ($msg) = @_;

    push @commands, sub { svn "ci", "-m", $msg }
}

1;
