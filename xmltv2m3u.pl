#!/usr/bin/perl

# Jerry Fath jerryfath at gmail dot com
#
#Read an xml file produced by xmltv and use the data to create an m3u playlist and
#sources file for tvheadend and node-ffmpeg-mpegts-proxy
#
# 
#Copyright (c) 2017 Jerry Fath
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this
#software and associated documentation files (the "Software"), to deal in the Software
#without restriction, including without limitation the rights to use, copy, modify,
#merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to the following
#conditions:
#
#The above copyright notice and this permission notice shall be included in all copies
#or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
#PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
#OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#DEALINGS IN THE SOFTWARE.
#

use 5.010;
use strict;
use warnings;

use File::Basename;
use File::stat;

#sudo apt-get install libxml-libxml-perl
#or
#sudo yum install "perl(XML::LibXML)"
use XML::LibXML;

#
#Customize these for your provider
my $iptvprovider = "Smithville Digital";
my $iptvsource = "http://192.168.222.90:8080/hdmi";
my $iptvpre = "/home/hts/tvh/pre.sh";
my $iptvpost = "/home/hts/tvh/post.sh";
#Indexes for full channel name and number with the xml display-name array
my $nameindex = 4;
my $numberindex = 2;

sub badusage {
    print "Usage: xmltv2m3u.pl infile.xml\n";
    exit -1;
}

#chack that a filename was passed
my $argcnt = @ARGV;
if ( $argcnt != 1 ) {
    badusage();
}

my $infile = $ARGV[0];
#Check that infile exists
unless ( -f $infile) {
    print "Input file: $infile not found\n";
    badusage();
}

#create dom from xmltv file
my $dom = XML::LibXML->load_xml(location => $infile);

#Loop through each channel in the dom extracting needed info to a hash array
my @channelinfo;
foreach my $channel ( $dom->findnodes('//channel') ) {
    my $displaynames = join ',', map {
        $_->to_literal();
    } $channel->findnodes('./display-name');

    my @names = split(',', $displaynames);

    push @channelinfo, { 'name' => $names[$nameindex], 'number' => $names[$numberindex] };
}

#sort channel info hash array by channel name
@channelinfo = sort { lc($a->{name}) cmp lc($b->{name}) } @channelinfo;

#Open output files
#Get basename from infile and use .m3u and .json extensions
my ($inbase, $indirs, $inext) = fileparse($infile, qr/\.[^.]*/);

#open the m3u and json sources files and write headers
my $outm3u = $indirs . $inbase . ".m3u";
my $outjson = $indirs . $inbase . ".json";

print "Writing $outm3u and $outjson\n";

open FILEM3U, ">", "$outm3u" or die $!;
open FILEJSON, ">", "$outjson" or die $!;

print FILEM3U "#EXTM3U\n";
print FILEJSON "[\n";

#Loop through each hash writing file entries
my $channelcnt = 0;
foreach my $channelitem ( @channelinfo ) {

    #write m3u entry for channel
    print FILEM3U "#EXTINF:0," . $channelitem->{'name'} . "\n";
    print FILEM3U "http://127.0.0.1:9128/" . $channelitem->{'number'} . "\n";

    #write sources entry for channel
    if ($channelcnt != 0) {
        print FILEJSON ",\n";
    }
    print FILEJSON "    {\n";
    print FILEJSON '        "name": ' . '"' . $channelitem->{'name'} . '"' . ",\n";
    print FILEJSON '        "provider": ' . '"' . $iptvprovider . '"' . ",\n";
    print FILEJSON '        "url": ' . '"/' . $channelitem->{'number'} . '"' . ",\n";
    print FILEJSON '        "source": ' . '"' . $iptvsource . '"' . ",\n";
    print FILEJSON '        "prescript": ' . '"' . $iptvpre . '"' . ",\n";
    print FILEJSON '        "postscript": ' . '"' . $iptvpost . '"' . ",\n";
    print FILEJSON '        "realtime": false' . "\n";
    print FILEJSON "    }";

    $channelcnt++;
}

print FILEJSON "\n]\n";

close FILEM3U;
close FILEJSON;

print "m3u and sources written.  ",  $channelcnt , " channels found.\n";
