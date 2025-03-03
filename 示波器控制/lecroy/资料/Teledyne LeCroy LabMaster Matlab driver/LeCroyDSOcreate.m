function [deviceObj, interfaceObj, appObj]=LeCroyDSOcreate(IPaddress)
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

% Set scope address (default 172.25.1.2)
if isempty(IPaddress)
    scopeIPaddress = '172.25.1.1';
else
    scopeIPaddress = IPaddress;
end

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
deviceObj = icdevice('TeledyneLecroy_LabmasterScopes.mdd', interfaceObj);

% Connect device object to hardware.
connect(deviceObj);

% Instantiate of Scope Application object at the IP address referenced. 
% (Use 127.0.0.1 when running MATLAB on the scope)
appObj = actxserver('LeCroy.XStreamDSO.1', IPaddress);



