ThingHTTP_APIKEYS = struct('To_Trigger_TalkBack','0JLKPTWN4D80HVQM','To_Trigger_alter','QOZIO1S7T4L8L29C');% Your ThingHTTP app API keys
url = 'https://api.thingspeak.com/apps/thinghttp/send_request';
Trigger_TalkBack = webread(url,'api_key',ThingHTTP_APIKEYS.To_Trigger_TalkBack); %Trigger TalkBack via ThingHTTP
Trigger_sendAlter = webread(url,'api_key',ThingHTTP_APIKEYS.To_Trigger_alter); %send alter via ThingHTTP
