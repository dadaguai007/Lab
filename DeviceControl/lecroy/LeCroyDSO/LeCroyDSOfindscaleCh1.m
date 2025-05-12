function LeCroyDSOfindscaleCh1(deviceObj, appObj)
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

% if length(cl)~=4
%     disp('error: length of the channel list is wrong.');
% end
    
groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand', 'VBS app.Acquisition.Horizontal.SampleMode="RealTime"'); % Set the mode of acquisition to realtime sampling

groupObj = get(deviceObj, 'Acquisition');
groupObj = groupObj(1);
% set(groupObj, 'State', 'stop'); % Stop acquistion

samplerate = 80e9;
memory = 2e6;

captureinterval=1/samplerate*memory;
acq = appObj.Object.Item('Acquisition'); % creation of acquisition object  
hor = acq.Object.Item('Horizontal'); % creation of horizontal object 1 level down from acquisition-level

meas = appObj.Object.Item('Measure'); % creation of measure object
p2 = meas.Object.Item('P2'); % amplitude
amp = p2.Out.Result.Value;

new_scale = ceil(max(0.005,amp/0.8/10)*1000);
groupObj = get(deviceObj, 'Util');
groupObj = groupObj(1);
invoke(groupObj, 'sendcommand',sprintf('VBS app.Acquisition.C1.VerScale=%3.3f',new_scale/1000));

% % Disconnect device object from hardware.
% disconnect(deviceObj);
% 
% % Delete objects.
% delete([deviceObj interfaceObj]);
