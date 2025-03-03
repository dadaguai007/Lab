function [deviceObj, interfaceObj, appObj]=LeCroyDSOcreate(IPaddress)
% SH 8/29/2014
% Note that when running MATLAB from a remote PC,
% you need to log on using 'admin' acount on the oscilloscope.(Switch user)

% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', IPaddress, 'RemotePort', 1861, 'Tag', '');

% scopeIPaddress = '10.10.10.3';
% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
%     interfaceObj = tcpip('172.25.1.1', 1861);
    interfaceObj = tcpip(IPaddress, 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end
    
% Create a device object. 
deviceObj = icdevice('TeledyneLecroy_LabmasterScopes.mdd', interfaceObj);

% Connect device object to hardware.
connect(deviceObj);

% Instantiate of Scope Application object at the IP address referenced. 
% (Use 127.0.0.1 when running MATLAB on the scope)
% To make a connection to the oscilloscope application
appObj = actxserver('LeCroy.XStreamDSO.1', IPaddress);



