%% Channels IDs & Channels API
% Sensor ChannelID
sensorChannelID = 2472648;
% Sensor Channel ReadAPI
sensorReadAPI = 'HRV40X4D515PGVFT';

%system modeChannelID
systemChannelID = 2522218;
%system mode ChannelID ReadAPI
systemReadAPI = '28MU4DB4XNB9IEWX';

% Plant ChannelID
plantChannelID = 2500177;
% Plant Channel ReadAPI 
plantReadAPI = 'TLGVH539FJS33WKW';

%% Check System Auto or Manual
%System mode 
systemMode = thingSpeakRead(systemChannelID, 'Fields', 1, ReadKey=systemReadAPI);

% Auto = 1 , manual = 0
if systemMode == 1
     % Get Temperature and Humidity SensorData
    SensorData = thingSpeakRead(sensorChannelID, 'Fields', [2,3,5], ReadKey=sensorReadAPI);
   
    %Get Temperature 
    Temperature =SensorData(1);
    %Get Humidity 
    Humidity = SensorData(2);
    %Get Rain 
    RainSensor=SensorData(3);
  
    % Plant  Temperature and Humidity
    plantMoisture = thingSpeakRead(plantChannelID, 'Fields', [2,3], ReadKey=plantReadAPI);
    %Get plant Temperature 
    plantTemperature = plantMoisture(1);
    %Get plant Humidity 
    plantHumidity = plantMoisture(2);
   
% TalkBack app ID
TalkBack_ID = '52134'; 

% TalkBack app API key
TalkBack_apikey = 'XJB7KX6ZNU6CDFD4';
%url to send commands to TalkbackAPP
url =  strcat('https://api.thingspeak.com/talkbacks/',TalkBack_ID,'/commands.json');

%% Check if Temperature and Humidity greate than or equal threshold plant Temperature and Humidity
if Temperature >= plantTemperature
 response = webwrite(url,'api_key',TalkBack_apikey,'command_string','close Roof');
    disp("close Roof");
elseif Temperature <= plantTemperature
    if RainSensor == 1  % Not Raining
        response = webwrite(url,'api_key',TalkBack_apikey,'command_string','open Roof');
        disp("open Roof");
    end
end
disp(response);
end
