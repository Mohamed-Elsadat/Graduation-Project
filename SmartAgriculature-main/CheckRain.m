%% Channels IDs & Channel API 
% Sensor ChannelID
sensorChannelID = 2472648;
% Sensor Channel ReadAPI
sensorReadAPI = 'HRV40X4D515PGVFT';

% Plant ChannelID
plantChannelID = 2500177;
% Plant Channel ReadAPI 
plantReadAPI = 'TLGVH539FJS33WKW';

% Farm Status ChannelID
FarmChannelID = 2522297;
% Farm Channel ReadAPI 
FarmReadAPI = '21DDFR6F71VOSPCA';

%system modeChannelID
systemChannelID = 2522218;
%system mode ChannelID ReadAPI
systemReadAPI = '28MU4DB4XNB9IEWX';

%% Check if system mode Auto or manual
%System mode 
systemMode = thingSpeakRead(systemChannelID, 'Fields', 1, ReadKey=systemReadAPI);
% Auto = 1 , manual = 0 
if systemMode == 1
% Get % RainSensor and Moisture SensorData
SensorData = thingSpeakRead(sensorChannelID, 'Fields', [1,5], ReadKey=sensorReadAPI);

RainSensor = SensorData(2);
Moisture = SensorData(1); 

% Check roof status
RoofStatus = thingSpeakRead(FarmChannelID, 'Fields', 2, ReadKey=FarmReadAPI);

% Plant Moisture (corrected variable name)
plantMoisture = thingSpeakRead(plantChannelID, 'Fields', 1, ReadKey=plantReadAPI);


% TalkBack app ID
TalkBack_ID = '52134'; 
% TalkBack app API key
TalkBack_apikey = 'XJB7KX6ZNU6CDFD4';
%url to send commands to TalkbackAPP
url =  strcat('https://api.thingspeak.com/talkbacks/',TalkBack_ID,'/commands.json');

% Check If It Is Raining
% RainSensor = 1 --> Not Raining 
if RainSensor == 0 % RainSensor = 0 --> Raining
    %check if soil need to irrigation
    if Moisture >= plantMoisture  
        response = webwrite(url,'api_key',TalkBack_apikey,'command_string','open Roof');
        disp("open Roof");
    else
        response = webwrite(url,'api_key',TalkBack_apikey,'command_string','close Roof');
        disp("close Roof");
    end
end

end
