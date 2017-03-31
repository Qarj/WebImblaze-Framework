#Prints out all the URLS in a HAR File
#Usage harURLs.pl harfile.txt
$harfile = @ARGV[0];

open(HAR, "$harfile")  || die("Could not open the input file!");
@raw_data=<HAR>;
close(HAR);

foreach $line (@raw_data) #There is actually only one line in the HAR file from browsermob proxy
{
    while ($line =~ m!"url":"([^"]*)"!g) #while loop for each match
        {
            print "$1\n";
        }
}
