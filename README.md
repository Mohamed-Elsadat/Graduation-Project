

# Smart Agriculture System

## Project Summary

This project implements a smart agriculture system using the ThingSpeak platform. The system consists of multiple channels that store various sensor data and control different aspects of the farm. The system includes functionalities for monitoring soil moisture, temperature, humidity, flame, rain, and tank levels, and controlling a pump and roof based on sensor readings.

## ThingSpeak Channels

1. **Smart Agriculture**: Stores sensor data such as moisture, temperature, humidity, flame, rain, and tank levels.
2. **Plant Data**: Stores user-selected plant data such as moisture, temperature, and humidity.
3. **Smart Agriculture Mode**: Handles system mode (manual or auto) with a single field, "Mode".
4. **Farm Status**: Monitors farm status such as the pump and roof.

## ThingSpeak Apps

ThingSpeak apps are used to write code and perform actions based on channel data. This project uses the following apps:

1. **ThingHTTP**: Sends HTTP requests based on channel data.
2. **ThingTweet**: Sends tweets based on channel data.
3. **MATLAB Analysis**: Analyzes channel data and performs actions.
4. **ThingSpeak Alerts**: Sends alerts via email when certain conditions are met.
5. **TalkBack**: Enables devices to act on queued commands (e.g., open or close the roof based on soil moisture).

## React App

The React app works with ThingHTTP, ThingTweet, and MATLAB Analysis apps to perform actions when channel data meets certain conditions. For example, a mobile app can report your location to a ThingSpeak channel, and when you're within a certain distance of your house, ThingHTTP can turn on your living room lights. This project also handles inactivity by sending alerts to your email if no data is sent to the channel.

## Project Code Explanation

The project code includes various functions to handle sensor data, control the pump and roof, monitor tank levels, and send alerts. Below is a detailed explanation of the code:

### Channel IDs & API Keys

```matlab
% Sensor ChannelID
sensorChannelID = 2472648;
% Sensor Channel ReadAPI
sensorReadAPI = 'HRV40X4D515PGVFT';
% 2472648 is a channel ID of Smart Agriculture ,And HRV40X4D515PGVFT is Read API Keys Use this key to allow other people to view your private channel feeds and charts.

% Plant ChannelID
plantChannelID = 2500177;
% Plant Channel ReadAPI
plantReadAPI = 'TLGVH539FJS33WKW';
% 2500177is a channel ID of Plant Data And 'TLGVH539FJS33WKW' is Read API Keys Use this key to allow other people to view your private channel feeds and charts.

% System mode ChannelID
systemChannelID = 2522218;
% System mode ChannelID ReadAPI
systemReadAPI = '28MU4DB4XNB9IEWX';
% 2522218 is a channel ID of Smart Agriculture Mode ,And '28MU4DB4XNB9IEWX'is Read API Keys Use this key to allow other people to view your private channel feeds and charts.

% TalkBack app ID
TalkBack_ID = '52134';
% TalkBack app API key
TalkBack_apikey = 'XJB7KX6ZNU6CDFD4';
% URL to send commands to TalkBack APP
url = strcat('https://api.thingspeak.com/talkbacks/', TalkBack_ID, '/commands.json');
%'52134' is a TalkBack_ID And 'XJB7KX6ZNU6CDFD4' is TalkBack_apikey used to connect to this talkBack url use to send commands to TalkbackAPP

% ThingSpeak Alerts API Key
alertApiKey = 'TAKKc2NXdxJhbsnnNcF';
% Set the address for the HTTP call
alertURL = "https://api.thingspeak.com/alerts/send";
% Web options for alerts
options = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertApiKey]);
%'TAKKc2NXdxJhbsnnNcF' is a alertApiKey use to send alert to mail if any condition has been ,The Alerts REST API schedules emails to be sent when you send a request to api.thingspeak.com/alerts/send ,webwrite uses weboptions to add required headers. Alerts need a ThingSpeak-Alerts-API-Key
```

### Global Variables

```matlab
controlroof = 1;
```

### Functions

#### Check Moisture

Checks soil and plant moisture levels and controls the pump accordingly.

This function use to check if a Soil Misture is greater than or equal to PlantMoisture and if this condition is True the PUMP will OPEN A command to turn on the water pump (TURN_ON_PUMP) is sent using webwrite

Else the PUMP will CLOSE The response from the web service is displayed.

This function take (soilMoisture,plantMoisture,TalkBack_apikey,url) As prameters and display soilMoisture,plantMoisture
TalkBack_apikey: The API key for authorization with the web service. url: The URL of the web service to send commands to
isnan(soilMoisture): Checks if the soilMoisture value is NaN (Not a Number), indicating a sensor error or missing data.
catch ME: Catches any errors that occur during the execution of the try block.

```matlab
function CheckMoisture (soilMoisture, plantMoisture, RainSensor, TalkBack_apikey, url)
    persistent lastPumpCommand;
    if isempty(lastPumpCommand)
        lastPumpCommand = -1;
    end

    if isnan(soilMoisture)
        disp(["Moisture sensor is ", soilMoisture]);
    elseif isnan(plantMoisture)
        disp(["Plant Moisture is ", plantMoisture]);
    else
        try
            if (soilMoisture >= plantMoisture && RainSensor)
                if (lastPumpCommand == 0 || lastPumpCommand == -1)
                    lastPumpCommand = 1;
                    response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_ON_PUMP');
                    disp("True ON PUMP");
                end
            else
                if (lastPumpCommand == 1 || lastPumpCommand == -1)
                    lastPumpCommand = 0;
                    response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_OFF_PUMP');
                    disp("True OFF PUMP");
                end
            end
        catch ME
            disp('An error occurred:');
            disp(ME.message);
        end
    end
end
```

#### Check Rain

Checks rain sensor data and controls the roof based on soil moisture levels.

RainSensor == 0: Checks if the rain sensor indicates that it is raining (assuming 0 means rain). The second condition

if it raining Moisture >= plantMoisture: Checks if the soil moisture is above the threshold needed by the plant.

If it is raining and the soil needs irrigation (moisture level is above or equal to the threshold), it sends a command to open the roof (TURN_ON_ROOF) using webwrite.

If the soil does not need irrigation, it sends a command to close the roof (TURN_OFF_ROOF) using webwrite. 

If it is not raining (RainSensor is not 0), it simply displays a message indicating no action is taken.

This function take (RainSensor,Moisture,plantMoisture,TalkBack_apike,url) As prameters and display soilMoisture 

if isnan(RainSensor): Checks if the RainSensor value is NaN (Not a Number) and display plantMoisture

if isnan(plantMoisture): Checks if the plantMoisture value is NaN (Not a Number)

TalkBack_apikey: The API key for authorization with the web service. url: The URL of the web service to send commands to
catch ME: Catches any errors that occur during the execution of the try block.

```matlab
function CheckRain(RainSensor, Moisture, plantMoisture, TalkBack_apikey, url)
    if isnan(RainSensor)
        disp(["Rain Sensor is ", RainSensor]);
    elseif isnan(plantMoisture)
        disp(["Plant Moisture is ", plantMoisture]);
    else
        persistent lastRoofCommand;
        if isempty(lastRoofCommand)
            lastRoofCommand = -1;
        end

        if RainSensor == 0
            try
                if Moisture >= plantMoisture
                    if (lastRoofCommand == 0 || lastRoofCommand == -1)
                        lastRoofCommand = 1;
                        response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_ON_ROOF');
                        disp("Open Roof");
                    end
                else
                    if (lastRoofCommand == 1 || lastRoofCommand == -1)
                        lastRoofCommand = 0;
                        response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_OFF_ROOF');
                        disp("Close Roof");
                    end
                end
            catch ME
                disp('An error occurred:');
                disp(ME.message);
            end
        else
            disp("It is not raining, no action taken.");
        end
    end
end
```

#### Check Temperature

Checks temperature and humidity levels and controls the roof accordingly.

If the temperature is greater than or equal to the plant's required temperature (Temperature >= plantTemperature), it sends a command to close the roof (close Roof) using webwrite.

If the temperature is less than or equal to the plant's required temperature (Temperature <= plantTemperature), it checks the rain condition.

If RainSensor == 1 (assuming 1 means not raining), it sends a command to open the roof (open Roof) using webwrite.

If it is raining (RainSensor != 1), it sets the response to "No action taken because it is raining."

If neither condition is met, it sets the response to "No action taken."

This function take (Temperature,Humidity,plantTemperature,plantHumidity,TalkBack
_apikey,url) As prameters and display Temperature if

isnan(Temperature) || isnan(Humidity):Checks if the Temperature and Humidity value is NaN (Not a Number)
and display plantTemperature and plantHumidity if

isnan(plantTemperature) || isnan(plantHumidity): Checks if the plantTemperature and plantHumidity value is NaN (Not a Number)

TalkBack_apikey: The API key for authorization with the web service. url: The URL of the web service to send commands to
catch ME: Catches any errors that occur during the execution of the try block.

```matlab
function CheckTemperature(Temperature, Humidity, plantTemperature, plantHumidity, TalkBack_apikey, url)
    if isnan(Temperature) || isnan(Humidity)
        disp(["Temperature & Humidity sensor is ", Temperature]);
    elseif isnan(plantTemperature) || isnan(plantHumidity)
        disp(["Plant Temperature is ", plantTemperature]);
        disp(["Plant Humidity is ", plantHumidity]);
    else
        persistent lastRoofCommand;
        if isempty(lastRoofCommand)
            lastRoofCommand = -1;
        end
        try
            if Temperature >= plantTemperature
                if (lastRoofCommand == 1 || lastRoofCommand == -1)
                    lastRoofCommand = 0;
                    response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_OFF_ROOF');
                    disp("TURN_OFF_ROOF");
                end
            elseif Temperature <= plantTemperature
                if (lastRoofCommand == 0 || lastRoofCommand == -1)
                    lastRoofCommand = 1;
                    response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'TURN_ON_ROOF');
                    disp("TURN_ON_ROOF");
                end
            else
                response = 'No action taken because it is raining.';
            end
        catch ME
            disp('An error occurred:');
            disp(ME.message);
        end
    end
end
```

#### Monitor Tank Level

Monitors tank level and sends an alert if the tank is empty.

This function take (TankData,alertURL,options) As prameters If TankData == 1, it indicates the tank is empty
The function sets the alert body and subject messages to indicate that the tank is empty, It then displays a message "Tank is empty".

If TankData == 0, it indicates the tank is full It displays a message "Tank is Full ".
The function attempts to send an alert using webwrite with the alertURL, alertBody, alertSubject, and options.

If the alert is sent successfully, it displays the response from the web service.

If an error occurs during the webwrite function, it catches the exception and displays an error message. and display TankData if isnan(TankData):Checks if the TankData value is NaN (Not a Number)
catch ME: Catches any errors that occur during the execution of the try block.

```matlab
function MonitorTankLevel(TankData, alertURL, options)
    if isnan(TankData)
        disp(["Tank Sensors is ", TankData]);
    else
        persistent lastAlert;
        if isempty(lastAlert)
            lastAlert = 1;
        end
        if TankData == 1 && lastAlert
            alertBody = 'Tank Is Empty';
            alertSubject = 'Tank Status Alert: Empty';
            lastAlert = 0;
            disp('Tank is empty');
            try
                response = webwrite(alertURL, "body", alertBody, "subject", alertSubject, options);
                disp('Alert sent successfully.');
                disp("Response:");
                disp(response);
            catch ME
                disp('Failed to send alert:');
                disp(ME.message);
            end
        elseif TankData == 0
            lastAlert = 1;
            disp('Tank is not empty.');
        end
    end
end
```

#### Monitor Flame Sensor

Monitors flame sensor data and sends an alert if fire is detected.

This function take (FlameData,alertURL,options) As prameters

If FlameData == 1, it indicates that a fire has been detected.

The function sets the alert body and subject messages to indicate the presence of fire. It then displays a message "Fire detected! Sending alert...". If FlameData == 0, it indicates that no fire has been detected. It displays a message "No fire detected.".

The function attempts to send an alert using webwrite with the alertURL, alertBody, alertSubject, and options.

If the alert is sent successfully, it displays the response from the web service.

If an error occurs during the webwrite function, it catches the exception and displays an error message.

and display FlameData if isnan(FlameData):Checks if the FlameData value is NaN (Not a Number)
catch ME: Catches any errors that occur during the execution of the try block.

```matlab
function MonitorFlameSensor(FlameData, alertURL, options)
    if isnan(FlameData)
        disp(["Flame Sensors is ", FlameData])
    else
        if FlameData == 1
            alert_body = 'There is a fire';
            alert_subject = 'ThingSpeak Alert email';
            disp('Fire detected! Sending alert...');
            try
                response = webwrite(alertURL, "body", alert_body, "subject", alert_subject, options);
                disp('Alert sent successfully.');
                disp("Response:");
                disp(response);
            catch ME
                disp('An error occurred while sending the alert:');
                disp(ME.message);
            end
        else
            disp('No fire detected.');
```

#### Check System Auto or Manual

The thingSpeakRead function returns the value of field 1 from the specified channel, storing it in the variable systemMode.

if systemMode == 1: Checks if the systemMode value is 1, indicating that the system is in automatic mode. If true, the code within the if block will execute.

```matlab
systemMode = thingSpeakRead(systemChannelID, 'Fields', 1, ReadKey=systemReadAPI); 
% Auto = 1 , manual = 0 if systemMode == 1
```

