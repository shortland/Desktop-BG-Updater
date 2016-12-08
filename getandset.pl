#!/usr/bin/perl

use Cwd;

$restart = 0;
RESTART:
my @choices =
(
	"https://www.reddit.com/r/EarthPorn",
	"https://www.reddit.com/r/skyporn",
	"https://www.reddit.com/r/WinterPorn",
	"https://www.reddit.com/r/SpringPorn"
);

$choice = @choices[int(rand(4))];
$bind = `curl -s -A "i'm not a bot I swer. mac osx safari" "$choice" -L`;
$identifier = 'data-url="';

$useTop = int(rand(20));

for(0..$useTop)
{
	$bind =~ s/$identifier//;
}
#$bind =~ s/$identifier/Ω/;
#print $bind;
$bigMoney = "data-url";
($imageLink) = ($bind =~ /$bigMoney[^:]*:([^"]+)/);
#print $imageLink;
$imageLink = "http:".$imageLink;
if($imageLink !~ m/.jpg|.jpeg|.png/)
{
	$restart++;
	if($restart =~ /^(10)$/){die "10 failed attemps at fetching a valid picture D:\n";}
	sleep(1);
	goto RESTART;
}
if($imageLink =~ m/.jpg/){$extension = ".jpg";}
if($imageLink =~ m/.jpeg/){$extension = ".jpeg";}
if($imageLink =~ m/.png/){$extension = ".png";}

$imageRaw = `curl -s -A "i'm not a bot I swer. mac osx safari" "$imageLink" -L`;

my @chars = ("A".."Z", "a".."z", "0".."9");
my $newName;
$newName .= $chars[rand @chars] for 1..8;
$newName = "botfetch_".$newName;

open(my $fh, '>', $newName.$extension);
print $fh $imageRaw;
close $fh;

$rep = 0;
$fileName = $newName.$extension;
RECHECK:
if(-e $fileName)
{
	$currentDir = cwd();
	$file = $currentDir."/$newName$extension";
	`osascript -e 'tell application "Finder" to set desktop picture to POSIX file "$file"'`;

	print qq
	{	
		Image Source: $imageLink, \n
		Local File Name: $newName$extension, \n
		Sub Pick: $choice, \n
		UseTop: $useTop \n
	};
}
else
{
	sleep(1); # sometimes it tries to se the desktop pic b4 the pic even downloads from curl process.
	$rep = $rep + 1;
	if($rep =~ /^(6)$/){die "ERROR:: UNABLE TO SAVE IMAGE::; \nImage Source: $imageLink, \n Local File Name: $newName$extension, \n Sub Pick: $choice, \n UseTop: $useTop \n\n";}
	goto RECHECK;
}

