function [T, Y]=LeCroyDSOgetwaveform(deviceObj, interfaceObj, cl, samplerate, recordlength)
% Sample script for Teledyne LeCroy LabMaster oscilloscopes, demonstrating
% various types of driver commands.  Please setup your 8 or more channel
% scope using "ScopeSetupForLabmasterDriverTest.lss" file.  You can also
% explore the driver usign the "Test and Measurement Tool" (type "tmtool"
% at the MATLAB command prompt.

% clc;
% 
% % Set scope address (default 127.0.0.1 is local loopback, for running
% % MATLAB directly on the scope itself
% scopeIPaddress = '127.0.0.1';
% 
% % Create a TCPIP object.
% interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', scopeIPaddress, 'RemotePort', 1861, 'Tag', '');
% 
% % Create the TCPIP object if it does not exist
% % otherwise use the object that was found.  Put the IP address of the
% % oscilloscope below
% if isempty(interfaceObj)
%     interfaceObj = tcpip(scopeIPaddress, 1861);
% else
%     fclose(interfaceObj);
%     interfaceObj = interfaceObj(1);
% end
%     
% % Create a device object. 
% deviceObj = icdevice('Lecroy_LabmasterScopes.mdd', interfaceObj);
% 
% % Connect device object to hardware.
% connect(deviceObj);

% if length(cl)~=4
%     disp('error: length of the channel list is wrong.');
% end
    
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

% Set record length. 
% set(interfaceObj, 'InputBufferSize', recordlength);
% Set timebase. 
groupObj = get(deviceObj, 'Acquisition');
groupObj = groupObj(1);
set(groupObj, 'Timebase', samplerate);

numofch=length(cl);
Y=zeros(numofch,recordlength);

% Enable the channel inputs
groupObj = get(deviceObj, 'Display');
groupObj = groupObj(1);
for i=1:numofch
set(deviceObj.Channel(cl(i)), 'State', 'on');   
end

% Now get waveform data from Channels.
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);
for i=1:numofch
[Y(i), T, YUNIT, XUNIT, HEADER] = invoke(groupObj, 'readwaveform', sprintf('channel%d',cl(i)));
end

figure(1); clf;
subplot(221)
plot(T, Y(1),'r-'); grid on; hold on; title('c1')
subplot(222)
plot(T, Y(2),'r-'); grid on; hold on; title('c2')
subplot(223)
plot(T, Y(3),'r-'); grid on; hold on; title('c3')
subplot(224)
plot(T, Y(4),'r-'); grid on; hold on; title('c4')

% Disconnect device object from hardware.
disconnect(deviceObj);

% Delete objects.
delete([deviceObj interfaceObj]);
