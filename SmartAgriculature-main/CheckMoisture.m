%% Channels IDs & Channels API
% Sensor ChannelID
sensorChannelID = 2472648;
% Sensor Channel ReadAPI
sensorReadAPI = 'HRV40X4D515PGVFT';

% Plant ChannelID
plantChannelID = 2500177;
% Plant Channel ReadAPI 
plantReadAPI = 'TLGVH539FJS33WKW';

%system modeChannelID
systemChannelID = 2522218;
%system mode ChannelID ReadAPI
systemReadAPI = '28MU4DB4XNB9IEWX';

%% Check System Auto or Manual
%System mode 
systemMode = thingSpeakRead(systemChannelID, 'Fields', 1, ReadKey=systemReadAPI);
% Auto = 1 , manual = 0
if systemMode == 1
% Moisture SensorData
soilMoisture = thingSpeakRead(sensorChannelID, 'Fields', 1, ReadKey=sensorReadAPI);
% Plant Moisture (corrected variable name)
plantMoisture = thingSpeakRead(plantChannelID, 'Fields', 1, ReadKey=plantReadAPI);

% TalkBack app ID
TalkBack_ID = '52134'; 
% TalkBack app API key
TalkBack_apikey = 'XJB7KX6ZNU6CDFD4'; 
%url to send commands to TalkbackAPP
url =  strcat('https://api.thingspeak.com/talkbacks/',TalkBack_ID,'/commands.json');

%% Check Conditions for Moisture
if soilMoisture >= plantMoisture 
  response = webwrite(url,'api_key',TalkBack_apikey,'command_string','ON pump');
    disp("True ON PUMP");
else
    response = webwrite(url,'api_key',TalkBack_apikey,'command_string','OFF pump');
    disp("True OFF PUMP");
end
disp("Respone");
disp(response);
end
