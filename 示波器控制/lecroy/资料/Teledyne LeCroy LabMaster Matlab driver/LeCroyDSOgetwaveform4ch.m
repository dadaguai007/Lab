function [T1, Y1, Y2, Y3, Y4, DSO]=LeCroyDSOgetwaveform4ch(deviceObj, appObj, cl, samplerate, memory)
% HG 5/22/2014
% Note that when running MATLAB from a remote PC,
% you need to log on using 'admin' acount on the oscilloscope.(Switch user)

% See the following for detailed instructions
% "Automation Command Reference Manual"
% "X-Stream COM Object Programming with MATLAB"
% "REMOTE CONTROL MANUAL"
% "dcom_setup_for_windows7_pc"
% "dcom_setup_for_windows7_scope"
% "Teledyne LeCroy LabMaster driver for Matlab"
% "Getting Started Manual"

if length(cl)~=4
    disp('error: length of the channel list is wrong.');
end
    
groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.SampleMode="RealTime"'); % Set the mode of acquisition to realtime sampling

groupObj = get(deviceObj, 'Acquisition');
groupObj = groupObj(1);
% set(groupObj, 'State', 'stop'); % Stop acquistion

captureinterval=1/samplerate*memory;
acq = appObj.Object.Item('Acquisition'); % creation of acquisition object  
hor = acq.Object.Item('Horizontal'); % creation of horizontal object 1 level down from acquisition-level
set(hor, 'SampleMode', 'RealTime'); % Set the sample mode to real time
set(hor, 'SampleRate', samplerate); % Set the sample rate From 200000 to 8e+010, locked to 1 2 4 8
DSO.SamplingRate = get(hor.Item('SamplingRate'), 'Value'); % Get the actual sample rate
fprintf('Acual Sampling Rate is %e\n', DSO.SamplingRate);
set(hor, 'Maximize', 'FixedSampleRate'); % Set the timebase controls to fixed sample rate
set(hor, 'HorScale', captureinterval/10); % Set the horizontal scale in time per division, From 2e-011 to5e-010, locked to 1 2 5
actualHorScale = get(hor.Item('HorScale'), 'Value'); % Get the horizontal scale in time per division
fprintf('Acual Memory is %e\n', actualHorScale*10*DSO.SamplingRate);
DSO.memory=actualHorScale*10*DSO.SamplingRate;

% Enable the channel inputs
set(deviceObj.Channel(1), 'State', 'on');   
set(deviceObj.Channel(2), 'State', 'on');   
set(deviceObj.Channel(3), 'State', 'on');   
set(deviceObj.Channel(4), 'State', 'on');   

groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C1.View=True');
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C2.View=True');
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C3.View=True');
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.C4.View=True');

% Set a variable to align channel waveforms using VBS script.  With this
% variable True, all the channels on the screen would be sampled at the
% same exact time instance.
groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');

% Set the bandwidth limit for channel Cx
set(deviceObj.Channel(1), 'BandwidthLimit', 'off'); 
set(deviceObj.Channel(2), 'BandwidthLimit', 'off'); 
set(deviceObj.Channel(3), 'BandwidthLimit', 'off'); 
set(deviceObj.Channel(4), 'BandwidthLimit', 'off'); 

% Get the bandwidth limit for channel Cx
DSO.bandwidthlimit.ch1 = get(deviceObj.Channel(1), 'BandwidthLimit'); 
DSO.bandwidthlimit.ch2 = get(deviceObj.Channel(2), 'BandwidthLimit'); 
DSO.bandwidthlimit.ch3 = get(deviceObj.Channel(3), 'BandwidthLimit'); 
DSO.bandwidthlimit.ch4 = get(deviceObj.Channel(4), 'BandwidthLimit'); 

% % Set trigger source to C1
% groupObj = get(deviceObj, 'Trigger');
% groupObj = groupObj(1);
% set(groupObj, 'Source', 'channel1');

% Set trigger mode to auto
groupObj = get(deviceObj, 'Trigger');
groupObj = groupObj(1);
set(groupObj, 'Mode', 'auto');

% Now get waveform data from Channels.
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);

[Y1, T1, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
[Y2, T2, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel2');
[Y3, T3, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel3');
[Y4, T4, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel4');

% figure(1); clf;
% subplot(221)
% plot(T1, Y1,'r-'); grid on; hold on; title('c1')
% subplot(222)
% plot(T2, Y2,'r-'); grid on; hold on; title('c2')
% subplot(223)
% plot(T3, Y3,'r-'); grid on; hold on; title('c3')
% subplot(224)
% plot(T4, Y4,'r-'); grid on; hold on; title('c4')

% % Disconnect device object from hardware.
% disconnect(deviceObj);
% 
% % Delete objects.
% delete([deviceObj interfaceObj]);
