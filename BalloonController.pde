// -------------------------------------------------------------------------------------------------
// TBD - TBD
// A project of HackPittsburgh (http://www.hackpittsburgh.org)
//
// Copyright (c) 2010 Jonathan Speicher (jonathan@hackpittsburgh.org)
// Licensed under the MIT license: http://creativecommons.org/licenses/MIT
// -------------------------------------------------------------------------------------------------

// Define the data sampling rate in milliseconds.

#define DATA_SAMPLING_RATE_MS 60000    // 60000 ms = 1 min

// Define the transmit and receive pins that the GPS module is connected to.

#define GPS_RECEIVE_PIN  2
#define GPS_TRANSMIT_PIN 3

// Define the Arduino digital pins that the analog multiplexer is connected to.

#define ANALOG_MUX_PIN_S0     0
#define ANALOG_MUX_PIN_S1     1
#define ANALOG_MUX_PIN_S2     2
#define ANALOG_MUX_PIN_S3     3
#define ANALOG_MUX_SIGNAL_PIN 0

// Define the analog multiplexer channels for each sensor.

#define ANALOG_MUX_CHANNEL_ACCELEROMETER_X 0
#define ANALOG_MUX_CHANNEL_ACCELEROMETER_Y 1
#define ANALOG_MUX_CHANNEL_ACCELEROMETER_Z 2

// Define the maximium data string length in characters.  This includes the terminating null.

#define MAX_DATA_STRING_LENGTH 255

// Define a variable to keep track of the last log time in milliseconds.

uint32_t s_lastLogMillis = 0;

// Setup is run once at the beginning of each sketch, loop runs continuously -----------------------

void setup()
{ 
  initLog();
  logString("------ Begin Logging ------");
  
  initGps(GPS_RECEIVE_PIN, GPS_TRANSMIT_PIN);
  initAnalogMux(ANALOG_MUX_PIN_S0, ANALOG_MUX_PIN_S1, ANALOG_MUX_PIN_S2, ANALOG_MUX_PIN_S3);
  accel_init(ANALOG_MUX_SIGNAL_PIN);
  
  char logFilename[15];
  getLogFilename(logFilename);
  
  Serial.begin(9600);
  Serial.println(logFilename);
}

void loop()
{
  feedgps();
  
  if (millis() >= s_lastLogMillis + DATA_SAMPLING_RATE_MS)
  {
    logAccelerometerData();
    logGpsData();
    logFlush();  
    s_lastLogMillis = millis();  
  }
}

// Helper functions --------------------------------------------------------------------------------

void logAccelerometerData()
{
  Serial.println("Logging accelerometer data");
  
  selectAnalogMuxChannel(ANALOG_MUX_CHANNEL_ACCELEROMETER_X);
  accel_sample_x();
  
  selectAnalogMuxChannel(ANALOG_MUX_CHANNEL_ACCELEROMETER_Y);
  accel_sample_y();
  
  selectAnalogMuxChannel(ANALOG_MUX_CHANNEL_ACCELEROMETER_Z);
  accel_sample_z();
  
  char dataString[MAX_DATA_STRING_LENGTH];
  accel_get_all(dataString);
  logString(dataString);
}

void logGpsData()
{
  Serial.println("Logging GPS data");
  
  gpsdump();
  
  String dataStringObject = GetGPSDataCSV();
  char dataString[MAX_DATA_STRING_LENGTH];
  dataStringObject.toCharArray(dataString, MAX_DATA_STRING_LENGTH);
  logString(dataString);
}
