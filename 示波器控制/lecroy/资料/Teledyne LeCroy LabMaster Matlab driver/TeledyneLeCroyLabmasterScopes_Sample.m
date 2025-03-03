% Sample script for Teledyne LeCroy LabMaster oscilloscopes, demonstrating
% various types of driver commands.  Please setup your 8 or more channel
% scope using "ScopeSetupForLabmasterDriverTest.lss" file.  You can also
% explore the driver usign the "Test and Measurement Tool" (type "tmtool"
% at the MATLAB command prompt.

clc;

% Set scope address (default 127.0.0.1 is local loopback, for running
% MATLAB directly on the scope itself
% scopeIPaddress = '172.25.1.1';
scopeIPaddress = '10.10.10.3';

% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', scopeIPaddress, 'RemotePort', 1861, 'Tag', '');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.  Put the IP address of the
% oscilloscope below
if isempty(interfaceObj)
    interfaceObj = tcpip(scopeIPaddress, 1861); 
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end
    
% Create a device object. 
deviceObj = icdevice('TeledyneLeCroy_LabmasterScopes.mdd', interfaceObj);
                      
% Connect device object to hardware.
connect(deviceObj);

% Set a variable to align channel waveforms using VBS script.  With this
% variable True, all the channels on the screen would be sampled at the
% same exact time instance.
groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.EnableAlignChannelSamples="1"');

% Set trigger source to C2
groupObj = get(deviceObj, 'Trigger');
groupObj = groupObj(1);
set(groupObj, 'Source', 'channel1');

% Do 2 acquisitions of waveforms with different record lengths/timebases.
for i = 1:2
    % Set timebase.
	groupObj = get(deviceObj, 'Acquisition');
	groupObj = groupObj(1);
	set(groupObj, 'Timebase', i*5e-8)

	% Now get waveform data from Channel 1.
	groupObj = get(deviceObj, 'Waveform');
	groupObj = groupObj(1);
	[Y, T, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
    figure(1); clf;
    subplot(221)
    plot(T, Y,'b-x'); grid on; hold on; title('c2')	
end

% % Now get waveform from channel 5
% [Y1, T1, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel5');
% subplot(222)
% plot(T1, Y1,'r-'); grid on; hold on; title('c5')
% 
% % Get waveform from math 12
% [Y1, T1, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'math12');
% subplot(223)
% plot(T1, Y1,'r-'); grid on; hold on; title('m12')
% 
% % Get waveform from channel 6
% [Y1, T1, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel6');
% subplot(224)
% plot(T1, Y1,'r-'); grid on; hold on; title('c6')
% 
% % Generate beeps!
% invoke(deviceObj, 'beep');
% 
% % Get present Volts/div setting of C2 and C5
% vdivC2 = get(deviceObj.Channel(2), 'Scale');
% vdivC5 = get(deviceObj.Channel(5), 'Scale');
% 
% % Change Volts/div setting of C5
% set(deviceObj.Channel(5), 'Scale', 0.2);

% Disconnect device object from hardware.
disconnect(deviceObj);

% Delete objects.
delete([deviceObj interfaceObj]);
