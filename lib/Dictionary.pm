package Dictionary;

use strict;
use warnings;

use WordChooser;
use Category;
use WordChooser::SimpleWordChooser;
use Word;

use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

our $VERSION = 0.1;

sub new { 
 my $self = bless {}, $_[0];
 $self->{words} = {};
 $self->setWordChooser(SimpleWordChooser->new($self->{words}));
}

# mapa englishName => Word
sub words { $_[0]->{words}; }

# Parametry w kolejnosci polishName, englishName, category  
# polishName  - znaczenie polskie
# englishName - znaczenie angielksie
# category    - kategoria slówka
sub addWord {
 my $self = shift;
 my $word = $self->_getWord(@_);
 $self->{words}{$word->englishName()} = $word; 
}

sub _getWord {
 my $self = shift;
 my $word = Word->new($_[1], $_[0], $_[2]);
 $word->setOccurrence($_[5]) if defined $_[5];
 $word->setGoodAnswers($_[4]) if defined $_[4];
 $word;
}

sub getWordChooser { $_[0]->{wordChooser}; }
sub setWordChooser { $_[0]->{wordChooser} = $_[1]; $_[0]; }

sub _getXls() { $_[0]->{xls}; }
sub _setXls { $_[0]->{xls} = $_[1]; $_[0]; }

sub _getXlsStatsSheet() { $_[0]->{xlsStatsSheet}; }
sub _setXlsStatsSheet() { $_[0]->{xlsStatsSheet} = $_[1]; $_[0]; }

sub _getXlsFileName() { $_[0]->{fileName}; }
sub _setXlsFileName() { $_[0]->{fileName} = $_[1]; $_[0]; }

sub writeStatsToXls() {
 my $self = shift;
 my $worksheet = $self->_getXlsStatsSheet();
 my $col = 0;
 my $row = 0;
 foreach (qw( ANG. POL. CAT. BAD. GOOD. ALL.)) {
  $worksheet->AddCell( $row, $col++, $_ );
 }
 
 my $iterator = SimpleWordChooser->new($self->{words});
 for($row = 1; $iterator->hasNext(); $row++) {
  my $word = $iterator->nextWord();
  if($word->occurrence() > 0) {
   $col = 0;
   $worksheet->AddCell( $row, $col++, $word->englishName() );
   $worksheet->AddCell( $row, $col++, $word->polishName() );
   my $cats = "None";
   if($word->categories() > 0) {
       $cats = join(',', map { $_->name() } $word->categories());;
   }
   $worksheet->AddCell( $row, $col++, $cats );
   $worksheet->AddCell( $row, $col++, 
       $word->occurrence() - $word->goodAnswers());
   $worksheet->AddCell( $row, $col++, $word->goodAnswers() );
   $worksheet->AddCell( $row, $col++, $word->occurrence() );
  }
 }
 $self->_getXls()->SaveAs($self->_getXlsFileName());
}

sub loadXls() {
 my $self = shift;
 my $fileName = shift;
 
 $self->_setXlsFileName($fileName);
 binmode(STDOUT, ":utf8");
 print "Starting Parsing xls[$fileName]\n";
 my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
 my $xls = $parser->Parse($fileName);
 $self->_setXls($xls);
 
 print "..Fetching Legend\n" 
     and Category->loadXls($xls->worksheet('LEGEND')) 
         if defined $xls->worksheet('LEGEND');
 
 for my $worksheet ( $xls->worksheets() ) {
  ($worksheet->get_name() eq "LEGEND") and next;
  ($worksheet->get_name() eq "STATS") and next;
  $self->loadWordsXls($worksheet);
 }
 
 print "..Fetching Stats\n" and 
     $self->_loadWordsStatsXls($xls->worksheet('STATS')) 
         if defined $xls->worksheet('STATS');
         
}

sub _loadWordsStatsXls {
 my $worksheet = $_[1];
 $_[0]->_setXlsStatsSheet($worksheet);
 $_[0]->_loadXlsWorkSheet($worksheet, 0,
  
     sub {
          my $self = shift;
          my @params = @{ +shift };
          my $word = $self->_getWord(@params);
          $self->words()->{$word->englishName()}->copyStats($word);
     }
     
 );
 $_[0];
}

sub _loadXlsWorkSheet {
 my $worksheet = $_[1];
 my $colMaxDif = $_[2];
 my $funHandler = $_[3];
 
 my ( $rowMin, $rowMax ) = $worksheet->row_range();
 my ( $colMin, $colMax ) = $worksheet->col_range();
 for my $row ($rowMin + 1 .. $rowMax) {
  my @line;
  for my $col ( $colMin .. $colMax - $colMaxDif ) {
   my $cell = $worksheet->get_cell( $row, $col );
   next unless $cell;
   push @line, $cell->value(); 
  }
  $_[0]->$funHandler(\@line) if (@line > 0 and length $line[0] > 0);
 }
 $_[0];
}

sub loadWordsXls {
 my $worksheet = $_[1];
 my ( $rowMin, $rowMax ) = $worksheet->row_range();
 my ( $colMin, $colMax ) = $worksheet->col_range();
 for my $row ($rowMin + 1 .. $rowMax) {
  my @line;
  for my $col ( $colMin .. $colMax - 1 ) {
   my $cell = $worksheet->get_cell( $row, $col );
   next unless $cell;
   push @line, $cell->value(); 
  }
  $_[0]->addWord(@line);
 }
 $_[0];
}

sub printDict {
 my $myself = shift;
 my %map = %{$myself->words};
 for my $key (keys %map) {
  print "$key => " . $map{$key}->toString . " \n";
 } 
}

1;