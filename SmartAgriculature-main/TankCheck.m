% Sensors Channel ID
SensorChannelID = 2472648;
% Sensors Channel Read API Key
SensorReadAPI = 'HRV40X4D515PGVFT';

% System Mode Channel ID
systemChannelID = 2522218;
% System Mode Channel Read API Key
systemReadAPI = '28MU4DB4XNB9IEWX';

% ThingSpeak Alerts API Key
alertApiKey = 'TAKKc2NXdxJhbsnnNcF';

% Set the address for the HTTP call
alertURL = "https://api.thingspeak.com/alerts/send";

% webwrite uses weboptions to add required headers. Alerts need a ThingSpeak-Alerts-API-Key header.
options = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertApiKey]);

% Tank minimum threshold
Tank_min = 0;

% Read System Mode
SystemMode = thingSpeakRead(systemChannelID, 'Fields', 1, 'ReadKey', systemReadAPI);


disp(SystemMode);

if SystemMode == 1

    % Read Tank Sensor Data
    TankData = thingSpeakRead(SensorChannelID, 'Fields', 6, 'ReadKey', SensorReadAPI);

    TalkBack_ID = '52134';
    TalkBack_apikey = 'XJB7KX6ZNU6CDFD4';
   %Tank  full --> 0 
    if TankData == 1 % empty ---> 1
        alertBody = 'Tank Is Empty';
        alertSubject = 'Tank Status Alert: Empty';
        disp('Tank is empty');
        
        % Send alert
        try
            webwrite(alertURL, "body", alertBody, "subject", alertSubject, options);
            disp('Alert sent successfully.');
        catch ME
            disp('Failed to send alert:');
            disp(ME.message);
        end
        
        % Send TalkBack command to open the valve to fill the tank
        %url = strcat('https://api.thingspeak.com/talkbacks/', TalkBack_ID, '/commands.json');
        %response = webwrite(url, 'api_key', TalkBack_apikey, 'command_string', 'Open valve to fill tank');
       
    end
end
