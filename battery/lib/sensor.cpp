//Arduinoを用いた回路
const int PIN_TMP36 = 1;

void setup()
{
  pinMode(10, OUTPUT);
}

void loop()
{
  float a = analogRead(PIN_TMP36);
  float v = a * 5.0 / 1023.0;
  float t = v * 100 - 50;
  
  if (t < 30.0) {
    digitalWrite(10, 1);
  } else {
    digitalWrite(10, 0);
  }
  
  delay(3000);
}