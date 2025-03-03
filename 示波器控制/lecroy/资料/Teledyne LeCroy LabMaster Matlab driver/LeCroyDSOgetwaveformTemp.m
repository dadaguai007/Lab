% function [T, Y]=LeCroyDSOgetwaveform(deviceObj, interfaceObj, cl, samplerate, recordlength)
% Sample script for Teledyne LeCroy LabMaster oscilloscopes, demonstrating
% various types of driver commands.  Please setup your 8 or more channel
% scope using "ScopeSetupForLabmasterDriverTest.lss" file.  You can also
% explore the driver usign the "Test and Measurement Tool" (type "tmtool"
% at the MATLAB command prompt.

clc;

IPaddress='172.25.1.1';
samplerate=40e9;
memory=3e3;
recordlength=memory;
cl=[1, 2, 3, 4];


% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', '172.25.1.1', 'RemotePort', 1861, 'Tag', '');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = tcpip('172.25.1.1', 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object. 
deviceObj = icdevice('TeledyneLecroy_LabmasterScopes.mdd', interfaceObj);
% set(interfaceObj, 'InputBufferSize', 2000000);


% Connect device object to hardware.
connect(deviceObj);

%%
% % Execute device object function(s).
% groupObj = get(deviceObj, 'Waveform');
% groupObj = groupObj(1);
appObj = actxserver('LeCroy.XStreamDSO.1', IPaddress);

%%
%     
% if length(cl)~=4
%     disp('error: length of the channel list is wrong.');
% end
%     
% % Set a variable to align channel waveforms using VBS script.  With this
% % variable True, all the channels on the screen would be sampled at the
% % same exact time instance.
% groupObj = get(deviceObj, 'Util');
% groupObj = groupObj(1);
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');
% 
% %%
% captureinterval=1/samplerate*memory;
% acq = appObj.Object.Item('Acquisition'); % creation of acquisition object  
% hor = acq.Object.Item('Horizontal'); % creation of horizontal object 1 level down from acquisition-level
% set(hor, 'SampleMode', 'RealTime'); % Set the sample mode to real time
% set(hor, 'SampleRate', samplerate); % Set the sample rate From 200000 to 8e+010, locked to 1 2 4 8
% DSO.SamplingRate = get(hor.Item('SamplingRate'), 'Value'); % Get the actual sample rate
% fprintf('Acual Sampling Rate is %e\n', DSO.SamplingRate);
% set(hor, 'Maximize', 'FixedSampleRate'); % Set the timebase controls to fixed sample rate
% set(hor, 'HorScale', captureinterval/10); % Set the horizontal scale in time per division, From 2e-011 to5e-010, locked to 1 2 5
% actualHorScale = get(hor.Item('HorScale'), 'Value'); % Get the horizontal scale in time per division
% fprintf('Acual Memory is %e\n', actualHorScale*10*DSO.SamplingRate);
% DSO.memory=actualHorScale*10*DSO.SamplingRate;
% 
% groupObj = get(deviceObj, 'Util');
% groupObj = groupObj(1);
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C1.View=True');
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C2.View=True');
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C3.View=True');
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C4.View=True');
% 
% % Set a variable to align channel waveforms using VBS script.  With this
% % variable True, all the channels on the screen would be sampled at the
% % same exact time instance.
% groupObj = get(deviceObj, 'Util');
% groupObj = groupObj(1);
% invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');
% 
% % Set the bandwidth limit for channel Cx
% set(deviceObj.Channel(1), 'BandwidthLimit', 'off'); 
% set(deviceObj.Channel(2), 'BandwidthLimit', 'off'); 
% set(deviceObj.Channel(3), 'BandwidthLimit', 'off'); 
% set(deviceObj.Channel(4), 'BandwidthLimit', 'off'); 
% 
% % Get the bandwidth limit for channel Cx
% DSO.bandwidthlimit.ch1 = get(deviceObj.Channel(1), 'BandwidthLimit'); 
% DSO.bandwidthlimit.ch2 = get(deviceObj.Channel(2), 'BandwidthLimit'); 
% DSO.bandwidthlimit.ch3 = get(deviceObj.Channel(3), 'BandwidthLimit'); 
% DSO.bandwidthlimit.ch4 = get(deviceObj.Channel(4), 'BandwidthLimit'); 
% %%
% 
% % % Set trigger mode to auto
% % groupObj = get(deviceObj, 'Trigger');
% % groupObj = groupObj(1);
% % set(groupObj, 'Source', 'channel1');
% % set(groupObj, 'Mode', 'auto');
% 
% % Set record length. 
% % set(interfaceObj, 'InputBufferSize', recordlength);
% % Set timebase. 
% groupObj = get(deviceObj, 'Acquisition');
% groupObj = groupObj(1);
% set(groupObj, 'Timebase', samplerate);
% 
numofch=length(cl);
% % Y=zeros(numofch,recordlength);
% 
% % Enable the channel inputs
groupObj = get(deviceObj, 'Display');
groupObj = groupObj(1);
for i=1:numofch
set(deviceObj.Channel(cl(i)), 'State', 'on');   
end

% Now get waveform data from Channels.
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);


[Y1, T1, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
[Y2, T2, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel2');
[Y3, T3, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel3');
[Y4, T4, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel4');

% figure(1); clf;
% subplot(221)
% plot(T, Y(1),'r-'); grid on; hold on; title('c1')
% subplot(222)
% plot(T, Y(2),'r-'); grid on; hold on; title('c2')
% subplot(223)
% plot(T, Y(3),'r-'); grid on; hold on; title('c3')
% subplot(224)
% plot(T, Y(4),'r-'); grid on; hold on; title('c4')
% 
% % Disconnect device object from hardware.
% disconnect(deviceObj);
% 
% % Delete objects.
% delete([deviceObj interfaceObj]);
