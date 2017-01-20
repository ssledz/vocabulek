package SimpleWordChooser;

use strict;
use warnings;

our $VERSION = 0.1;

@SimpleWordChooser::ISA = qw(WordChooser);

sub nextIndex {
  if(!$_[0]->hasNext()) {
   $_[0]->{index} = 0;
 } else {
  ++$_[0]->{index};
 }
}

sub currentIndex { $_[0]->{index}; }

sub hasNext {
 $_[0]->{index} + 1 < keys %{$_[0]->words};
}

1;