
use Arduino::Pseudo;

my $arduino = Arduino::Pseudo->new();

$arduino->connect( 13 => 'led',
    pos => [ 10, 10 ],
    color => 'red',
);

$arduino->MainLoop;

sub loop {
    my($arduino) = @_;
    $arduino->digitalWrite(13, $arduino->HIGH);
    $arduino->delay(1000);
    $arduino->digitalWrite(13, $arduino->LOW);
    $arduino->delay(1000);    
}

__END__
/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
 
// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
int led = 13;

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);    
}

// the loop routine runs over and over again forever:
void loop() {
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);               // wait for a second
}
