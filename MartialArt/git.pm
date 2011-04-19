package MartialArt::git;

use strict;
use warnings;

use Cwd;
use File::Temp;
use File::Find;
use Archive::Tar;

my @commands;

my $home;
my $floor;
my $branch;

sub git {
    print "===> git ", join(" ", @_), "\n";
    system("git", @_) == 0 or die "Error executing git: $?";
}

sub bow_in {
    my ($class, $kata) = @_;

    $floor = File::Temp->newdir;
    $home = getcwd();
    chdir $floor->dirname;
    git "init";
    $branch = "master";
}

sub bow_out {
    my ($class, $kata) = @_;
    my $tar = Archive::Tar->new; 
    find(sub { $tar->add_files($File::Find::name) }, $floor->dirname);
    chdir $home;
    $tar->write("${kata}.tar.gz", COMPRESS_GZIP);
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

    print "===> creating $file with contents <$contents>\n";
    push @commands, sub { 
        open my ($target), "> $file";
        print $target $contents;
        close $target;

        git "add", $file;
    }
}

sub change {
    my ($file, $new_contents) = @_;

    print "===> changing $file to contain <$new_contents>\n";
    push @commands, sub { 
        open my ($target), "> $file";
        print $target $new_contents;
        close $target;

        git "add", $file;
    }
}

sub move {
    my ($file, $new_name) = @_;

    print "===> moving $file to $new_name\n";
    push @commands, sub {
        git "mv", $file, $new_name;
    }
}

sub commit {
    my ($msg) = @_;

    push @commands, sub { git "commit", "-a", "-m", $msg }
}

1;
