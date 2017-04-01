#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use File::Basename qw/basename dirname/;
use MIME::Base64 qw/encode_base64/;

use Encode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $DATA_DIR="/path/to/dir";

my $q = new CGI;
print $q->header( -charset => "utf-8", );

my $detail = decode("UTF-8",$q->param('detail'));
if (defined $detail and $detail ne "" ){
    open (my $wr,">>:utf8", "$DATA_DIR/data.csv") or die $!;
    say $wr time() . "," . encode_base64(encode("UTF-8",$detail),'');
    close $wr;
}
else {
    $detail = "";
}

print <<"HTML";
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Memo</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
    </head>
    <body>
        <a href="/@{[basename $0]}"><h1>Memo</h1></a>
        <div>
        @{[$q->escapeHTML($detail)]}
        </div>
        <form method="post" action="@{[basename $0]}">
            <textarea name="detail"></textarea><br><br>
            <input type="submit" value="memo">
        </form>
    </body>
</html>
HTML
