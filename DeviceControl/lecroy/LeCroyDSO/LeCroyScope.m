classdef LeCroyScope < handle
    %LeCroyScope is a class to control LecroyDSO
    %   Detailed explanation goes here
    % "TeledyneLecroy_LabmasterScopes.mdd" should be in the path
    
    properties
        IPaddr;
        SamplingRate = 80e9;
        Memory = 2e6;
        ChannelConfig = []; % when changed, re-config is required
        
        flagConfig = 0;
        flagConnect = 0;
        
        deviceObj;
        interfaceObj;
        appObj;
    end
    
    methods
        function obj = LeCroyScope(IPaddr)
            obj.IPaddr = IPaddr;
            obj.CreateScope();
            obj.flagConfig = 0;
        end
        
        function [data] = Capture(obj,filename)
            if nargin<2
                filename = [];
            end
            
            if ~obj.flagConfig
                obj.ConfigScope();
            end
            if ~obj.flagConnect
                connect(obj.deviceObj);
            end
            % Set trigger mode to single
            groupObj = get(obj.deviceObj, 'Trigger');
            groupObj = groupObj(1);
            set(groupObj, 'Mode', 'single');
            % Now get waveform data from Channels.
            groupObj = get(obj.deviceObj, 'Waveform');
            groupObj = groupObj(1);
            for iCh = 1:length(obj.ChannelConfig)
                ch = obj.ChannelConfig(iCh);
                [tmp, ~, YUNIT, XUNIT, HEADER] = invoke(groupObj,...
                    'readwaveform', sprintf('channel%d',ch));
                data(iCh,:) = tmp;
            end
            % Set trigger mode to auto
            groupObj = get(obj.deviceObj, 'Trigger');
            groupObj = groupObj(1);
            set(groupObj, 'Mode', 'auto');
            % Disconnect device object from hardware.
            disconnect(obj.deviceObj);
            obj.flagConnect = 0;
            % Save the file
            if ~isempty(filename)
                save(filename,'data');
            end
        end
        
        function [data,f] = CaptureMath(obj,filename,mathChID)
            if nargin<2
                filename = [];
                mathChID = 1;
            end
            
            if ~obj.flagConfig
                obj.ConfigScope();
            end
            if ~obj.flagConnect
                connect(obj.deviceObj);
            end
            % Set trigger mode to single
            groupObj = get(obj.deviceObj, 'Trigger');
            groupObj = groupObj(1);
            set(groupObj, 'Mode', 'single');
            % Now get waveform data from Channels.
            groupObj = get(obj.deviceObj, 'Waveform');
            groupObj = groupObj(1);
           
            [tmp, f, YUNIT, XUNIT, HEADER] = invoke(groupObj,...
                'readwaveform', sprintf('math%d',mathChID));
            data = tmp;

            % Set trigger mode to auto
            groupObj = get(obj.deviceObj, 'Trigger');
            groupObj = groupObj(1);
            set(groupObj, 'Mode', 'auto');
            % Disconnect device object from hardware.
            disconnect(obj.deviceObj);
            obj.flagConnect = 0;
            % Save the file
            if ~isempty(filename)
                save(filename,'data');
            end
        end
        
        function obj = CreateScope(obj)
            % copyright: SH 8/29/2014 "LeCroyDSOcreate.m"
            % Create a TCPIP object.
            ifObj = instrfind('Type', 'tcpip', 'RemoteHost', obj.IPaddr, 'RemotePort', 1861, 'Tag', '');
            if isempty(ifObj)
                %     interfaceObj = tcpip('172.25.1.1', 1861);
                ifObj = tcpip(obj.IPaddr, 1861);
            else
                fclose(ifObj);
                ifObj = ifObj(1);
            end
            % Create a device object.
            devObj = icdevice('TeledyneLecroy_LabmasterScopes.mdd', ifObj);
            % Connect device object to hardware.%
            connect(devObj);
            % Instantiate of Scope Application object at the IP address referenced.
            % (Use 127.0.0.1 when running MATLAB on the scope)
            % To make a connection to the oscilloscope application
            apObj = actxserver('LeCroy.XStreamDSO.1', obj.IPaddr);
            
            % set to the properties
            obj.interfaceObj = ifObj;
            obj.deviceObj = devObj;
            obj.appObj = apObj;
        end
        
        function [obj] = ConfigScope(obj)
            devObj = obj.deviceObj;
            apObj = obj.appObj;
            % configure the scope to real-time sampling mode
            groupObj = get(devObj, 'Util');
            groupObj = groupObj(1);
            invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.SampleMode="RealTime"'); % Set the mode of acquisition to realtime sampling
            groupObj = get(devObj, 'Acquisition');
            groupObj = groupObj(1);
            % set(groupObj, 'State', 'stop'); % Stop acquistion
            
            captureinterval=1/obj.SamplingRate*obj.Memory;
            acq = apObj.Object.Item('Acquisition'); % creation of acquisition object
            hor = acq.Object.Item('Horizontal'); % creation of horizontal object 1 level down from acquisition-level
            set(hor, 'SampleMode', 'RealTime'); % Set the sample mode to real time
            set(hor, 'SampleRate', obj.SamplingRate); % Set the sample rate From 200000 to 8e+010, locked to 1 2 4 8
            DSO.SamplingRate = get(hor.Item('SamplingRate'), 'Value'); % Get the actual sample rate
%             fprintf('Acual Sampling Rate is %e\n', DSO.SamplingRate);
            set(hor, 'Maximize', 'FixedSampleRate'); % Set the timebase controls to fixed sample rate
            set(hor, 'HorScale', captureinterval/10); % Set the horizontal scale in time per division, From 2e-011 to5e-010, locked to 1 2 5
            actualHorScale = get(hor.Item('HorScale'), 'Value'); % Get the horizontal scale in time per division
%             fprintf('Acual Memory is %e\n', actualHorScale*10*DSO.SamplingRate);
            DSO.memory=actualHorScale*10*DSO.SamplingRate;
            % Enable the channel inputs
            for iCh = 1:length(obj.ChannelConfig)
                ch = obj.ChannelConfig(iCh);
                set(devObj.Channel(ch), 'State', 'on');
            end
            % Enable view
            groupObj = get(devObj, 'Util');
            groupObj = groupObj(1);
            for iCh = 1:length(obj.ChannelConfig)
                ch = obj.ChannelConfig(iCh);
                invoke(groupObj, 'sendcommand', sprintf('VBS app.Acquisition.C%d.View=True',ch));
            end
            
            if length(obj.ChannelConfig) > 1
                % Set a variable to align channel waveforms using VBS script.  With this
                % variable True, all the channels on the screen would be sampled at the
                % same exact time instance.
                groupObj = get(devObj, 'Util');
                groupObj = groupObj(1);
                invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');
            end
            
            % Now set the config flag to be 1
            obj.flagConfig = 1;
            obj.flagConnect = 1;
        end
        function passflag = SelfTest(obj,flagPrint)
            if nargin<2
                flagPrint = 1;
            end
            if obj.flagConnect
                passflag = true;
                if flagPrint
                    fprintf('Device Self Test Passed!\nDevice Info: %s\n',message);
                end
            else
                passflag = false;
            end
        end
        function delete(obj)
            delete(obj.deviceObj)
            delete(obj.interfaceObj);
            delete(obj.appObj);
        end
    end
end
    
