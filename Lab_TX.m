addpath("DeviceControl\");
addpath("DeviceControl\KeysightAWG\");
addpath('DeviceControl\lecroy\LeCroyDSO\')
addpath('DeviceControl\Fncs\')
addpath('DeviceControl\PRBS\')

% 信号生成
ofdmGenerateTx;


% ipaddr = ['172.16.104.28'];
ipaddr = '192.168.1.10';
port = 5025;
modMethod = 'IQ';
model = 'M8195A_Rev1';
% 实验流程
lab = LabControl( ...
    [],  ...    % 是徳示波器
    [], ...       % lecroy示波器
    [], ...          % EXFO
    [], ...     % EXFO_Rs232
    [], ...     % 是徳功率计
    [], ...    % 安捷伦功率计
    KeysightAWG(ipaddr,port,modMethod,model), ...       % 是徳AWG
    [], ...        % 眼图仪
    [], ...      % 电谱仪5106
    [], ...          % 电谱仪5103
    [], ...        % DC
    []);          % 横河光谱仪

if 1
    % 信道响应
    [resp1,resp2,resp3,resp4]=lab.awgCalibration();
    save('Data\AWG_response.mat','resp1','resp2','resp3','resp4');
end


load('AWG_response.mat');

% 信道编号
chidx=[1,2];
% 纠正延时
fs=nn.Fs;
delay_ps=-1;
if 1
    % AWG发送信号
    lab.awgSendData(signal,fs,delay_ps,chidx);
else
    % AWG发送预补偿信号
    lab.awgPreComp(signal,fs,delay_ps,21e9,chidx,resp1,resp2,resp3,resp4)
end