package Word;

use strict;
use warnings;

our $VERSION = 0.1;

# polishName  - znaczenie polskie
# englishName - znaczenie angielksie
# category    - kategoria slówka
sub new {
 my $class = shift;
 my $self = bless {polishName => $_[0], englishName => $_[1], categories => [] }, $class;
 my @cats = Category->acro2Categories($_[2]);
 if(@cats > 0) {
  $self->setCategories(\@cats);
 }
 $self->setOccurrence(0)->setGoodAnswers(0);
}

# Tablica kategorii do ktorej nalezy slowo
sub categories {
 @{$_[0]->{categories}};
}

sub setCategories { $_[0]->{categories} = $_[1]; $_[0]; }

sub polishName { $_[0]->{polishName}; }
sub setPolishName { $_[0]->{polishName} = $_[1]; $_[0]; }

sub englishName { $_[0]->{englishName}; }
sub setEnglishName { $_[0]->{englishName} = $_[1]; $_[0]; }

# Ile razy dane slowko bylo zadane
sub occurrence { $_[0]->{occurrence}; }
sub setOccurrence { $_[0]->{occurrence} = $_[1]; $_[0]; }
sub incOccurrence { $_[0]->{occurrence}++; $_[0]; }

# Ilosc dobry odpowiedzi
sub goodAnswers { $_[0]->{goodAnswers}; }
sub setGoodAnswers { $_[0]->{goodAnswers} = $_[1]; $_[0]; }
sub incGoodAnswers { $_[0]->{goodAnswers}++; $_[0]; }

sub getChooseFactor {
 my $self = shift;
 my $goodProb = $self->goodAnswers / ($self->occurrence + 1);
 1 - $goodProb;
}

sub copyStats() {
 my $self = shift;
 my $word = shift;
 $self->setGoodAnswers($word->goodAnswers());
 $self->setOccurrence($word->occurrence());
}

sub toString {
 my @categories;
 for my $cat ($_[0]->categories) {
  push @categories, $cat->name;
 }
 return "Word: [polishName => " . $_[0]->polishName . ", " .
 "englishName => " . $_[0]->englishName . ", " .
 "occurrence => " . $_[0]->occurrence . ", " . 
 "goodAnswers => " . $_[0]->goodAnswers . ", " .
 "categories => " . join(', ', @categories) . "]";
}

1;

