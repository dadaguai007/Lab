function f = iqopen(ip_address,port)
if nargin < 2
    cfg.port = 5025; % default port
end

cfg.ip_address = ip_address;
cfg.port = port;

addr = cfg.ip_address;
i_list = instrfind('Type', 'tcpip', 'RemoteHost', cfg.ip_address, 'RemotePort', cfg.port);
if isempty(i_list)
    try
        f = tcpip(cfg.ip_address, cfg.port);
    catch e
        errordlg({'Error calling tcpip(). Please verify that' ...
            'you have the "Instrument Control Toolbox" installed' ...
            'MATLAB error message:' e.message}, 'Error');
        f = [];
    end
else
    f = i_list(1);
end

if (~isempty(f) && strcmp(f.Status, 'closed'))
    f.OutputBufferSize = 20000000;
    f.InputBufferSize = 6400000;
    f.Timeout = 20;
    try
        fopen(f);
    catch e
        errordlg({'Could not open connection to ' addr ...
            'Please verify that you specified the correct address' ...
            'in the "Configure Instrument Connection" dialog.' ...
            'Verify that you can communicate with the' ...
            'instrument using the Keysight Connection Expert'}, 'Error');
        f = [];
    end
end