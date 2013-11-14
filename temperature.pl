#!/usr/local/bin/perl

use Image::Magick;

# Gradient for Temperature (Summer):
# 20 = white-pink (255,200,255)
# 30 = pink (214,113,217)
# 40 = purple (140,54,186)
# 50 = blue (50,40,151)
# 60 = light blue (6,185,225)
# 70 = green-teal (1,213,119)
# 80 = green (108,207,3)
# 90 = yellow (255,250,0)
# 100 = orange (250,110,0)
# 110 = red (207,34,2)
# 120 = dark red (160,8,2)

$numGradientStops = 11;
@stopNum   = (  20,  30,  40,  50,  60,  70,  80,  90, 100, 110, 120);
@gradientR = ( 255, 214, 140,  50,   6,   1, 108, 255, 250, 207, 160);
@gradientG = ( 200, 113,  54,  40, 185, 213, 207, 250, 110,  34,   8);
@gradientB = ( 255, 217, 186, 151, 225, 119,   3,   0,   0,   2,   2);

# Write gradient to .csv
open (FILE, ">./temp_s/gradient.csv") or die "error.csv $!";
print FILE "Temperature_S\n";
for($i=0; $i<11; $i++) {
	print FILE "temp,$stopNum[$i],$gradientR[$i],$gradientG[$i],$gradientB[$i]\n";
}
close (FILE);

for($num=-40; $num<131; $num++) {
	$image=Image::Magick->new(size=>'21x21');
	$image->Read('xc:transparent');

	$r = 255 - 255 * $num / 100;
	$g = 255 - 255 * $num / 100;
	$b = 255 * $num / 100;

	for($index = 0; $index < $numGradientStops; $index++) {
		if ($num < $stopNum[0]) {
			$r = $gradientR[0];
			$g = $gradientG[0];
			$b = $gradientB[0];
			last;
		}
		if ($num > $stopNum[10]) {
			$r = $gradientR[10];
			$g = $gradientG[10];
			$b = $gradientB[10];
			last;
		}
		if ($num == $stopNum[$index]) {
			$r = $gradientR[$index];
			$g = $gradientG[$index];
			$b = $gradientB[$index];
			last;
		}
		if ($num < $stopNum[$index]) {
			$ratio = ($num - $stopNum[$index-1]) / ($stopNum[$index] - $stopNum[$index-1]);
			$r = $gradientR[$index-1] + $ratio * ($gradientR[$index] - $gradientR[$index-1]);
			$g = $gradientG[$index-1] + $ratio * ($gradientG[$index] - $gradientG[$index-1]);
			$b = $gradientB[$index-1] + $ratio * ($gradientB[$index] - $gradientB[$index-1]);
			last;
		}
	}

# See: http://www.nbdtech.com/Blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
# See: http://www.w3.org/TR/AERT#color-contrast
# See: http://alienryderflex.com/hsp.html

	$brightness  =  sqrt( .299 * $r * $r + .587 * $g * $g + .114 * $b * $b );

	$image->Draw(primitive=>'circle',stroke=>'none',fill=>'rgb(' . $r . ',' . $g . ',' . $b . ')',,
	  points=>"10,10 17,17");
	$image->Draw(primitive=>'circle',stroke=>'rgb(' . $r/2 . ',' . $g/2 . ',' . $b/2 . ')',fill=>'none',strokewidth=>.5,
	  points=>"10,10 17,17");

	if ($brightness > 127) {
		$textColor = 'black';
	}
	else {
		$textColor = 'white';
	}

# One character
	if (($num >= 0) && ($num <= 9)) {
		$textSize = 11;
		$textX = 8;
		$textY = 15;
	}
# Two characters
	elsif ( (($num >= -9) && ($num <= -1)) || (($num >= 10) && ($num <= 99)) ) {
		$textSize = 11;
		$textX = 5;
		$textY = 15;
	}
# Three characters, negative
	elsif (($num <= -10) && ($num >= -99)) {
		$textSize = 10;
		$textX = 3;
		$textY = 14;
	}
# Three characters, positive
	elsif (($num >= 100) && ($num <= 999)) {
		$textSize = 11;
		$textX = 1;
		$textY = 14;
	}

	$image->Annotate(text=>$num,geometry=>'+' . $textX . '+' .$textY. '',
	  font=>'Noxchi_Arial.ttf',fill=>$textColor,pointsize=>$textSize);

	$image->Write('./temp_s/' . $num . '.png');
}

# These values define the dimensions of the rectangle that will contain the gradient.
$barlen = 500;
$barheight = 24;

$imagesizestr = $barlen . 'x' . $barheight;
$imagebottom = $barheight - 1;

$image=Image::Magick->new(size=>$imagesizestr);
$image->Read('xc:transparent');

for($x=0; $x<$barlen; $x++) {

    # Here we map the bar to the range of values above so the comparison to the gradient stops
    # can be computed without transforming the stop values.
	$num = $stopNum[0] + ($x / ($barlen-30)) * ($stopNum[$numGradientStops-1] - $stopNum[0]);

	for($index = 0; $index < $numGradientStops; $index++) {
		if ($num == $stopNum[$index]) {
			$r = $gradientR[$index];
			$g = $gradientG[$index];
			$b = $gradientB[$index];
			last;
		}
		if ($num < $stopNum[$index]) {
			$ratio = ($num - $stopNum[$index-1]) / ($stopNum[$index] - $stopNum[$index-1]);
			$r = $gradientR[$index-1] + $ratio * ($gradientR[$index] - $gradientR[$index-1]);
			$g = $gradientG[$index-1] + $ratio * ($gradientG[$index] - $gradientG[$index-1]);
			$b = $gradientB[$index-1] + $ratio * ($gradientB[$index] - $gradientB[$index-1]);
			last;
		}
	}
	$stroke = 'rgb(' . $r . ',' . $g . ',' . $b . ')';
	
	if ($x >= 470) {
		$stroke = 'white';
	}

    $image->Draw(primitive=>'line',points=>"$x,0 $x,$imagebottom",stroke=>$stroke);

}

@summerLegend = (30,40,50,60,70,80,90,100,110);

for ($i=0; $i<10; $i++) {
	$red = $gradientR[($i+1)];
	$green = $gradientG[($i+1)];
	$blue = $gradientB[($i+1)];
	$brightness  =  sqrt( .299 * $red * $red + .587 * $green * $green + .114 * $blue * $blue );
	if ($brightness > 127) {
		$textColor = 'black';
	}
	else {
		$textColor = 'white';
	}
	$textSize = 12;
	$textX = (47 * ($i+1)) - ($textSize/2);
	$textY = 17;
	$text = "$summerLegend[$i]";
	
	$image->Annotate(text=>$text,geometry=>'+' . $textX . '+' .$textY. '',font=>'Noxchi_Arial.ttf',fill=>$textColor,pointsize=>$textSize);
}

$image->Annotate(text=>'°F',geometry=>'+480+17',font=>'Noxchi_Arial.ttf',fill=>'black',pointsize=>$textSize);

$image->Write('./temp_s/temp.png');
