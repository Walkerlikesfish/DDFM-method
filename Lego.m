% EIT Project Lego EV3 interacting with MATLAB par USB

%% Initialization

clear

mylego = legoev3('usb');
sensorList = mylego.readInputDeviceList;
[found, inport] = ismember('NXT_TEMP',sensorList); % detect and recogize NXT_TEMP sensor
tempSensor = tempSensor(mylego, inport);

tempSensor.readTemp