#define BLYNK_TEMPLATE_ID "YourTemplateID"
#define BLYNK_DEVICE_NAME "HealthRobot"
#define BLYNK_AUTH_TOKEN "YourAuthToken"

#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>
#include <Wire.h>
#include "MAX30100_PulseOximeter.h"

char ssid[] = "WiFiName";
char pass[] = "WiFiPassword";

PulseOximeter pox;
BlynkTimer timer;

#define THERMISTOR A0

// Motor pins
#define IN1 D5
#define IN2 D6
#define IN3 D7
#define IN4 D8

// Temperature reading
float readTemp() {
  int adc = analogRead(THERMISTOR);
  float voltage = adc * (3.3 / 1023.0);
  float tempC = voltage * 100;
  return tempC;
}

void sendSensor()
{
  pox.update();

  float heartRate = pox.getHeartRate();
  float spo2 = pox.getSpO2();
  float temp = readTemp();

  Blynk.virtualWrite(V0, heartRate);
  Blynk.virtualWrite(V1, spo2);
  Blynk.virtualWrite(V2, temp);
}

// Forward
BLYNK_WRITE(V3) {
  if (param.asInt()) {
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
  }
}

// Backward
BLYNK_WRITE(V4) {
  if (param.asInt()) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, HIGH);
  }
}

// Left
BLYNK_WRITE(V5) {
  if (param.asInt()) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
  }
}

// Right
BLYNK_WRITE(V6) {
  if (param.asInt()) {
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, HIGH);
  }
}

void setup()
{
  Serial.begin(9600);

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  Wire.begin(D2, D1);

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);

  if (!pox.begin()) {
    Serial.println("MAX30100 not found");
  }

  timer.setInterval(1000L, sendSensor);
}

void loop()
{
  Blynk.run();
  timer.run();
