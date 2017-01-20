package Category;

use strict;
use warnings;

our $VERSION = 0.1;

#use Spreadsheet::Read qw (cr2cell);

our %acro2CatMap;

sub new() {
 my $class = shift;
 bless {acronym => $_[0], name => $_[1]}, $class;
}

sub acronym { $_[0]->{acronym}; }
sub name { $_[0]->{name}; }

#sub loadXls {
# my $entry = $_[1];
# for(my $row = 2; $row <= $entry->{maxrow}; $row++) {
#  my @line;
#  for(my $col = 1; $col <= $entry->{maxcol}; $col++) {
#   my $cell = cr2cell ( $col, $row);
#   push @line, $entry->{$cell}; 
#  }
#  my $cat = Category->new(@line);
#  $acro2CatMap{$cat->acronym()} = $cat;
# }
#}

sub loadXls {
 
 my $worksheet = $_[1];
 my ( $rowMin, $rowMax ) = $worksheet->row_range();
 my ( $colMin, $colMax ) = $worksheet->col_range();
 
 for my $row ( $rowMin + 1 .. $rowMax ) {
  my @line;
  for my $col ( $colMin .. $colMax ) {
   my $cell = $worksheet->get_cell( $row, $col );
   next unless $cell;
   push @line, $cell->value(); 
  }
  my $cat = Category->new(@line);
  $acro2CatMap{$cat->acronym()} = $cat;
 }
 $_[0];
}

sub acro2Categories {
 my $class = shift;
 my @acronyms = split m#/\s*#, $_[0];
 my @cats = ();
 for (@acronyms) {
  push @cats, $acro2CatMap{$_} if defined($acro2CatMap{$_}); 
 }
 @cats;
}

sub printCategories {
 for my $key (keys %acro2CatMap) {
  print "$key => " . $acro2CatMap{$key}->toString . "\n";
 }
 
}

sub toString {
 return "Category: [acronym => " . $_[0]->acronym . ", " .
 "name => " . $_[0]->name . "]";
}

1;