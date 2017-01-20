use strict;
use warnings;


#use Dictionary;
use Word;
use Category;
use Win32::GUI;

my $splashimage = Win32::GUI::Bitmap->new("./resources/splashImage.bmp");
print $splashimage;

#get the dimensions of the bitmap
my ($width,$height)       = $splashimage->Info();
  
#create the splash window
my $splash     = new Win32::GUI::Window (
   -name       => "Splash",
   -text       => "Splash",
   -height     => $height, 
   -width      => $width,
   -left       => 100, 
   -top        => 100,
   -addstyle   => WS_POPUP,
   -popstyle   => WS_CAPTION | WS_THICKFRAME,
   -addexstyle => WS_EX_TOPMOST
);

#create a label in which the bitmap will be placed
my $bitmap    = $splash->AddLabel(
    -name     => "Bitmap",
    -left     => 0,
    -top      => 0,
    -width    => $width,
    -height   => $height,
    -bitmap   => $splashimage,
);  

#center the splash and show it
$splash->Center();
$splash->Show();
#call do events - not Dialog - this will display the window and let us 
#build the rest of the application.
Win32::GUI::DoEvents();

sleep(5);
$splash->Hide();
Win32::GUI::Dialog();