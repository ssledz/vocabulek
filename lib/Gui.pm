package Gui;

use strict;
use warnings;

use Win32::API;
use Win32::GUI ( qw (WS_CAPTION WS_THICKFRAME WS_EX_TOPMOST WS_POPUP CW_USEDEFAULT) );
use utf8;  # enable Perl to parse UTF-8 from this file
use Encode;
use Carp;

use Dictionary;

our $VERSION = 0.1;

our $questionLabel;
our $ansTxt;
our $dict;
our $dialog;
our $main;
our $splash;
our $SetWindowTextW_fn = undef; #do kodowania znakow z UTF-8 na UTF-16LE (Winda)

#Kodowanie znakow z UTF-8 na UTF-16LE (Winda)
sub _text {
 my ($control, $text) = @_;
 if (not $SetWindowTextW_fn) {
  $SetWindowTextW_fn = Win32::API->new("user32", "SetWindowTextW", "NP", "N");
  die unless $SetWindowTextW_fn;
 }
 $SetWindowTextW_fn->Call($control->{-handle}, _t2w($text));
}

sub _t2w {
   my ($text) = @_;
   return encode("UTF-16LE", $text . "\x00");
}

sub _showSplash() {
 my $splashimage = Win32::GUI::Bitmap->new("./resources/splashImage.bmp");

 #get the dimensions of the bitmap
 my ($width, $height)       = $splashimage->Info();
  
 #create the splash window
 $splash     = new Win32::GUI::Window (
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
}

sub _getFileName() {
 my @parms;
 my $lastfile;
 push @parms,
  -filter => ['XLS - Excel', '*.xls'],
  -directory => "c:\\Documents and Settings",
  -title => 'Select a file';
 push @parms, -file => $lastfile  if $lastfile;
 my @file = Win32::GUI::GetOpenFileName ( @parms );
 return $file[0] if defined $file[0];
 "" 
}

sub new() {
 
 _showSplash();
 $dict = Dictionary->new();
 sleep(5);
 $splash->Hide;
 my $fileName = _getFileName();
 length $fileName == 0  and croak "File: $fileName not found\n";
 $dict->loadXls($fileName);
 
 my $window = Win32::GUI::Window->new(
    -name   => 'Main', 
    -width => 300, 
    -height => 300,
    -text   => 'Perl',
    -onTerminate => sub { $dict->writeStatsToXls(); -1; }
 );
 $main = $window;
 my $self = bless {window => $window}, shift;
 $self->_init();
 $self->_center();
 $self;
}

sub _init() {
 my $self = shift;
 my $window = $self->{window};
 
 my $font = Win32::GUI::Font->new(
  -name => "Comic Sans MS", 
  -size => 26,
 );
 
 my $word = $dict->getWordChooser()->nextWord()->incOccurrence;;
 
 my $label = $window->AddLabel(
  -name => 'question',
  -text       => "",
  -font       => $font,
  -foreground => [255, 0, 0],
  -size => [290,40],
  -align => 'center'
 );
 
 _text($label, $word->polishName);
 
 $questionLabel = $label;
 
 my $txt = $window->AddTextfield(
    -name => 'ans',
    -text => "",
    -prompt => [ "Podaj odpowiedz:", 100 ],
    -top => $window->question->Top() + $window->question->Height() + 5,
    -size => [150,20],
    -align => 'left',
    -onKeyDown => sub { _doClick() if $_[2] == 13; }
);
 
 $ansTxt = $txt;
 
 my $btn = $window->AddButton(
  -text       => "Next",
  -name       => "btnNext",
  -left => $window->ans->Left() + $window->ans->Width() + 10,
  -top => $window->ans->Top(),
  -onClick => \&_doClick
 );
 
 my $ncw = $window ->Width()  - $window ->ScaleWidth();
 my $nch = $window ->Height() - $window ->ScaleHeight();
 my $w = $label->Left() + $btn->Width() + $label->Width() + $ncw;
 my $h = $label->Top() + $btn->Height() + $label->Height() + 10 + $nch;
 
 $self->{width} = $w;
 $self->{height} = $w;
 
 $window->Resize($w, $h);
 $window->Change(-minsize => [$w, $h]);
 $self->_initDialog;
  
}

sub _initDialog {
 $dialog = Win32::GUI::Window->new(
    -title => "Answer",
    -left => CW_USEDEFAULT,
    -size => [300,100],
    -toolwindow => 1,
    -onTerminate => sub { _doClick(); 0; },
    -onKeyDown => sub { _doClick() if $_[2] == 13; }
 );
 
 my $font = Win32::GUI::Font->new(
  -name => "Comic Sans MS", 
  -size => 80,
 );
 
 my $label = $dialog->AddLabel(
  -name => 'message',
  -text       => "OK",
  -font       => $font,
  -foreground => [255, 0, 0],
  -size => [250,100],
  -align => 'center'
 );
 
}

sub _center() {
 my $self = shift;
 my $window = $self->{window};
 my $desk = Win32::GUI::GetDesktopWindow();
 my $dw = Win32::GUI::Width($desk);
 my $dh = Win32::GUI::Height($desk);
 my $x = ($dw - $self->{width}) / 2;
 my $y = ($dh - $self->{height}) / 2;
 $window->Move($x, $y);
}

sub showGui() {
 my $self = shift;
 my $window = $self->{window};
 $window->Show();
 Win32::GUI::Dialog();
}

sub _doClick {
 
 if($dialog->IsVisible()) {
    do_animation('');
    $ansTxt->Text('');
    $main->btnNext->Text("Next");
    my $word = $dict->getWordChooser()->nextWord()->incOccurrence;
    _text($questionLabel,$word->polishName);
    return;
 }
  
 my $currentWord = $dict->getWordChooser()->currentWord();
 my $ans = $ansTxt->Text();
 if($ans eq $currentWord->englishName) {
    do_animation("Ok");
    $currentWord->incGoodAnswers();
 } else {
    do_animation("Wrong! : " . $currentWord->englishName);
 }
 
 $main->btnNext->Text("Close");
 
}  

sub do_animation {
  my $message = shift;
  $ansTxt->SetFocus();
  $dialog->message->Text($message);
  $dialog->Animate(
    -show => !$dialog->IsVisible(),
    -activate => 1,
    -animation => "slide",
    -direction => "tb",
    -time => 200,
    );
}

1;