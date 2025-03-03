%READWAVEFORM M-Code for communicating with an instrument. 
%  
%   This is the machine generated representation of an instrument control 
%   session using a device object. The instrument control session comprises  
%   all the steps you are likely to take when communicating with your  
%   instrument. These steps are:
%       
%       1. Create a device object   
%       2. Connect to the instrument 
%       3. Configure properties 
%       4. Invoke functions 
%       5. Disconnect from the instrument 
%  
%   To run the instrument control session, type the name of the M-file,
%   readwaveform, at the MATLAB command prompt.
% 
%   The M-file, READWAVEFORM.M must be on your MATLAB PATH. For additional information
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command
%   prompt.
%
%   Example:
%       readwaveform;
%
%   See also ICDEVICE.
%

%   Creation time: 20-May-2009 14:06:28 


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
set(interfaceObj, 'InputBufferSize', 2000000);


% Connect device object to hardware.
connect(deviceObj);

% Execute device object function(s).
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);

[Y1,X1,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
[Y2,X2,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel2');

% plot(X,Y); % plot figure
% title('WaveMaster Waveform Data'); % label title
% xlabel('s'); % label x axis
% ylabel('V'); % label y axis

% Delete objects.
delete([deviceObj interfaceObj]);

