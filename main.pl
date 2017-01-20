use lib 'lib';
use strict;
use warnings;

use Dictionary;
use Word;
use Category;
use Gui;

my $window = Gui->new();
$window->showGui();

#Application needs modules:
# 1. Win32::GUI
# 2. Spreadsheet::ParseExcel
# 3. Spreadsheet::WriteExcel
# 4. Spreadsheet::ParseExcel::SaveParser