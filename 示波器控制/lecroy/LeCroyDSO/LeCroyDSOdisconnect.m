function LeCroyDSOdisconnect(deviceObj, interfaceObj, appObj)
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

% Disconnect device object from hardware.
disconnect(deviceObj);

% Delete objects.
delete([deviceObj interfaceObj]);

% Delete application objects.
appObj.delete;