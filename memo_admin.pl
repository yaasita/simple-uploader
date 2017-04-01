#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename dirname/;
use MIME::Base64 qw/encode_base64 decode_base64/;
use feature qw(say);
use Time::Piece;

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $DATA_DIR="/path/to/dir";

my $q = new CGI;
print $q->header( -charset => "utf-8");

# 削除
if (defined $q->param("del")){
    my %list;
    open (my $in,"<","$DATA_DIR/data.csv") or die $!;
    while (<$in>){
        chomp;
        my ($time,$body) = split(/,/);
        $list{$time} = $body;
    }
    close $in;
    my @del = $q->param("del");
    for(@del){
        delete($list{$_});
    }
    open (my $wr,">", "$DATA_DIR/data.csv") or die $!;
    for ( sort keys(%list) ){
        print $wr $_ . "," . $list{$_} . "\n";
    }
    close $wr;
}

# 一覧
my %list;
{
    open (my $in,"<", "$DATA_DIR/data.csv") or die $!;
    while (<$in>){
        chomp;
        my ($time,$body) = split(/,/);
        $list{$time} = $body;
    }
    close $in;
}

my @tag = map { 
    my $key = $_;
    my $t = localtime($key);
    "<tr>\n" .
    "  <td>" . $t->strftime("%Y/%m/%d %H:%M:%S") . "</td>\n" .
    "  <td>" . decode("UTF-8",$q->escapeHTML(decode_base64($list{$key}))) . "</td>\n" .
    "  <td>" . qq/<input name="del" value="$key" type="checkbox">/ . "</td>\n" .
    "</tr>\n";

} sort (keys %list);

print <<"HTML";
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Memo/admin</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
    </head>
    <body>
        <a href="@{[basename $0]}"><h1>Memo/admin</h1></a>
        <form method="post" action="@{[basename $0]}">
            <table>
                <thead>
                    <tr>
                        <th>time</th>
                        <th>detail</th>
                        <th>del</th>
                    </tr>
                </thead>
                @tag
            </table>
            <br>
            <input type="submit" value="delete">
        </form>
    </body>
</html>
HTML
