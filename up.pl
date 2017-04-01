#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename/;
use File::Copy qw/move copy/;
use feature qw(say state);

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $DATA_DIR="/path/to/dir";
chdir $DATA_DIR or die $!;

my $q = new CGI;
print $q->header( -charset => "utf-8");

my @result;
{
    my @fhs = $q->upload('files');
    my %fname_count;
    for my $fh (@fhs){
        my $out_filename = non_overlapping_filenames("$fh");
        my $io_handle = $fh->handle;
        open (my $wr,">", $out_filename) or die $!;
        while (<$io_handle>){
            print $wr $_;
        }
        close $wr;
        push(@result, decode("UTF-8","$fh"));
    }
}

sub non_overlapping_filenames {
    my $filename = decode("UTF-8",$_[0]);
    $filename =~ s/[^\w\.]//g;
    my $ret;
    if ( ! -e $filename ){
        $ret = $filename;
    }
    else {
        my $i = 0;
        while(1){
            $i++;
            my $next_filename = $filename;
            $next_filename =~ s/(\..+)$/-$i$1/ or $next_filename .= "-$i";
            if (! -e $next_filename){
                $ret = $next_filename;
                last;
            }
        }
    }
    return encode("UTF-8",$ret);
}

print <<"HTML";
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Up</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
    </head>
    <body>
        <a href="/@{[basename $0]}"><h1>Up</h1></a>
        <div>
        @{[$q->escapeHTML("@result")]}
        </div>
        <form method="post" action="@{[basename $0]}" enctype="multipart/form-data">
            <input type="file" name="files" multiple />
            <input type="submit" value="submit" />
        </form>
    </body>
</html>
HTML
