package WordChooser;

use strict;
use warnings;

our $VERSION = 0.1;

sub new {
 my $class = shift;
 bless {words => $_[0], index => 0}, $class;
}

sub words { $_[0]->{words}; }

sub nextWord { 
 my @vals = values %{$_[0]->words};
 $vals[$_[0]->nextIndex];
}

sub currentWord {
 my @vals = values %{$_[0]->words};
 $vals[$_[0]->currentIndex];
}

sub hasNext { 0; }
sub nextIndex { 0; }
sub currentIndex { 0; }

1;
