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
$bind = `curl -s "$choice"`;
$identifier = '<div class="arrow down login-required access-required" data-event-action="downvote" role="button" aria-label="downvote" tabindex="0" ></div></div><a class="thumbnail may-blank " href="';

$useTop = int(rand(18));
for(0..$useTop)
{
	$bind =~ s/$identifier/∆/;
}
$bind =~ s/$identifier/Ω/;
($imageLink) = ($bind =~ /div[^Ω]*Ω([^"]+)/);

if($imageLink !~ m/.jpg|.jpeg|.png/)
{
	$restart = $restart + 1;
	if($restart =~ /^(10)$/){die "10 failed attemps at fetching a valid picture D:\n";}
	goto RESTART;
}
if($imageLink =~ m/.jpg/){$extension = ".jpg";}
if($imageLink =~ m/.jpeg/){$extension = ".jpeg";}
if($imageLink =~ m/.png/){$extension = ".png";}

$imageRaw = `curl -s $imageLink`;

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

