#!perl -T

use Test::More tests => 6;

BEGIN {
    use_ok( 'Arduino::Pseudo' ) || print "Bail out!\n";
    use_ok( 'Arduino::Pseudo::Thing' ) || print "Bail out!\n";
    use_ok( 'Arduino::Pseudo::PushButton' ) || print "Bail out!\n";
    use_ok( 'Arduino::Pseudo::LED' ) || print "Bail out!\n";
    use_ok( 'Arduino::Pseudo::Potentiometer' ) || print "Bail out!\n";
    use_ok( 'Arduino::Pseudo::LCD' ) || print "Bail out!\n";
}

diag( "Testing Arduino::Pseudo $Arduino::Pseudo::VERSION, Perl $], $^X" );
