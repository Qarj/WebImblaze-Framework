#Prints out all the URLS in a HAR File
#Usage harURLs.pl harfile.txt
$harfile = @ARGV[0];

open(HAR, "$harfile")  || die("Could not open the input file!");
@raw_data=<HAR>;
close(HAR);

my $headersSize=0;
my $bodySize=0;
my $grandTotal=0;

my @headers;
my @bodies;
my @urls;
my @gzips;


#
# First we overwrite url":" with an incrementing number like url000 url001 url002 etc
# It is important that we do not insert any characters, that will cause a massive delay,
# however overwriting existing characters is very quick
#
my $count=0;
$fcount = sprintf("%03d", $count); #Format number with up to 3 leading zeroes
foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ s!"url":"!"url$fcount!) #Note - must not use global in order to force it to loop and change the variable
        {
            $count = $count + 1;
            $fcount = sprintf("%03d", $count);
        }
     $line =~ s!$!"url$fcount!; #"#Throw on a dummy but incomplete url at the end so the gzip counting works even for the final url
}

#
# Here we save off each of the URLs in an array
#
my $count=0;
foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ m!"url\d\d\d([^"]*)"!g) #"while loop for each match
        {
            $urls[$count] = $1;
            #print "$1\n";
            $count = $count + 1;
        }
}

#
# Save off the header sizes in an array
#
my $count=0;
foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ m!"headersSize":([0-9]*)!g) #while loop for each match
        {
            #print "$1\n";
            $headersSize = $headersSize + $1;
            $headers[$count] = $1;
            $count = $count + 1;
        }
}
print "\nTotal of all headers: $headersSize \n";

#
# Save off the body sizes in an array
#
my $count=0;
foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ m!"bodySize":([0-9]*)!g) #while loop for each match
        {
            #print "$1\n";
            $bodySize = $bodySize + $1;
            $bodies[$count] = $1;
            $count = $count + 1;
        }
}
print "\nTotal of all bodies: $bodySize \n";

$grandTotal = $headersSize + $bodySize;
print "\nGrand Total: $grandTotal bytes \n\n\n";


#
# Now we just checked between two URLs eg url000 and url001 to see if there is a gzip in between
#
my $count=0;
$fca = sprintf("%03d", $count);
$fcb = sprintf("%03d", $count+1);
my $gzipcount=0;
foreach $url (@urls) #There is one header for the reqeust and one for the response
{
    $urla = $urls[$count];
    $urlb = $urls[$count+1];
    $gzips[$count]="    ";
    foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
    {
        while ($line =~ m!url$fca.*?"name":"Content-Encoding","value":".*?url$fcb!g) #"while loop for each match
            {
                $gzipcount=$gzipcount+1;
                $gzips[$count]="gzip";
                #print "$gzipcount ";
            }
    }
    $count=$count+1;
    $fca = sprintf("%03d", $count);
    $fcb = sprintf("%03d", $count+1);
    #print "$fca $fcb\n";
}


#
# Now we add up the sizes, and print out all the info at the same time
#
my $urlcount=0;
my $headercount=0;
my $checktotal=0;
foreach $url (@urls) #There is one header for the reqeust and one for the response
{
    my $totalsize = 0;
    $totalsize = $headers[$headercount] + $headers[$headercount+1];
    $totalsize = $totalsize + $bodies[$headercount] + $bodies[$headercount+1];
    print "$gzips[$urlcount] \t$totalsize \t$urls[$urlcount]\n";
    
    $checktotal = $checktotal + $totalsize;

    $urlcount = $urlcount + 1;
    $headercount = $urlcount * 2; #there are 2 headers and two bodies for each URL - i.e. request and response
}

print "\nTotal Transfered: $checktotal bytes\n\n";

#
# Finally we double check how many gzips are mentioned in the HAR file
#
my $count=0;
foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ m!"name":"Content-Encoding","value":"gzip"!g) #"while loop for each match
        {
            $count = $count + 1;
        }
}

print qq|\n"name":"Content-Encoding","value":"gzip" found $count times for $urlcount urls.\n\n|;
print qq|\ngzips found between urls: $gzipcount\n\n\n|;

#print @raw_data; 