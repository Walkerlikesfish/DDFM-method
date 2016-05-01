classdef tempSensor < realtime.internal.sensor
    % tempSensor is a modified class used to measure temperature with
    % NXT_TEMP sensor
    % prequisite: the class should be constructed based on legobrainstorm
    % support package provided by Mathworks
    
    methods
        function obj = tempSensor(ev3Handle, inputPort)
            % Constructor
            
            if nargin < 2
                sensorList = ev3Handle.readInputDeviceList;
                [found, inputPort] = ismember('NXT_TEMP', sensorList);  % Judging the sensor type specify to NXT_TEMP
                if ~found
                    error(message('legoev3io:build:TempNoSensorFound'));
                end
            end
            
            obj@realtime.internal.sensor(ev3Handle, inputPort);
            if obj.Type ~= realtime.internal.DeviceType.TYPE_NXT_TEMP
                error(message('legoev3io:build:TempNoSensorFoundOnPort', inputPort)); % Judging the sensor on the specified port(input)
            end
        end
        
        % Read distance
        function result = readTemp(obj)
            % readTemp - Read tempertaure
            %   readTemp(obj)
            %
            %   Outputs:
            %       result   - temperature value 
            %
            %   Example:
            %       readTemp(mysensor)
            
            result = read(obj, 0);
        end
    end  
end