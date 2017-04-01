#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename/;
use feature qw(say);
use Digest::MD5 qw(md5_hex);

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $q = new CGI;
print $q->header( -charset => "utf-8");

my $DATA_DIR="/path/to/dir";
chdir $DATA_DIR or die $!;

# 削除
if (defined $q->param("del")){
    my %files = list_files();
    my @del = $q->param("del");
    for(@del){
        unlink(encode("UTF-8",$files{$_}));
    }
}

# 一覧
my @tag;
{
    my %files = list_files();
    for (sort {$files{$a} cmp $files{$b}}  keys %files){
        my $md5 = $_;
        my $filename = %files{$md5};
        push(@tag,"<tr><td><a href=\"data/up/$filename\">$filename</a></td><td>" . qq/<input name="del" value="$md5" type="checkbox">/ . "</td></tr>");
    }
}
sub list_files {
    my @files = <*>;
    my %flist;
    for(@files){
        my $f = decode("UTF-8",$_);
        my $md5 = md5_hex(encode("UTF-8",$f));
        $flist{$md5}=$f;
    }
    return %flist;
}
print <<"HTML";
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Up/admin</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
    </head>
    <body>
        <a href="/@{[basename $0]}"><h1>Up/admin</h1></a>
        <form method="post" action="@{[basename $0]}">
            <table>
                <thead>
                    <tr>
                        <th>name</th>
                        <th>del</th>
                    </tr>
                    @{[join("\n",@tag)]}
                </thead>
            </table>
            <br>
            <input type="submit" value="delete">
        </form>
    </body>
</html>
HTML
