# xmltv2m3u.pl  
  
Read an xml file produced by xmltv and use the data to create an m3u playlist and
sources file for tvheadend and node-ffmpeg-mpegts-proxy  
  
Usage: xmltv2m3u.pl infile.xml  
  
Notes:  
  
requires XML::LibXML which can be installed as follows:  
sudo apt-get install libxml-libxml-perl  
    or  
sudo yum install "perl(XML::LibXML)"  
  
Edit xmltv2m3u.pl and change iptvprovider, iptvsource, iptvpre, and iptvpost as needed for your environment.  
  
Install and configure xmltv then produce the channel list file using:  
xmltv --config-file myconfig --list-channel --output channels.xml  
  
'xmltv2m3u.pl channels.xml' will write channels.m3u and channels.json in the same directory as channels.xml.  These files can be used as the playlist for a tvheadend IPTV automatic network and the sources file for node-ffmpeg-mpegts-proxy  
  
Copyright (c) 2017 Jerry Fath  
Jerry Fath jerryfath at gmail dot com  
MIT License (see source)  
