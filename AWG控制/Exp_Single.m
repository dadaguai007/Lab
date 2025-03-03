clear;close all;
warning('off');

addpath(genpath('DeviceControl'));
load('AWG_response.mat');
Freq_ch1 = resp1(:,1);
IMResponse_ch1 = resp1(:,2).*exp(1j*resp1(:,3));
Freq_ch2 = resp2(:,1);
IMResponse_ch2 = resp2(:,2).*exp(1j*resp2(:,3));

awg = KeysightAWG('192.168.1.10',5025,'IQ','M8195A_Rev1');
dso = KEYSIGHT93204A('192.168.1.99');
% dso = KEYSIGHT6004A('192.168.1.37');
delay_ps=5.5;% 870 240 780 220
OFDM_generation;
Ref=Creat_dither(nn.Fs,10e6,length(upSig)/(nn.Fs/10e6))';

if 0
    % AWG发送信号
    awg.AWGSamplingRate = nn.Fs;
    data_i = applyPreComp(real(result),nn.Fs,21e9,Freq_ch1,1./IMResponse_ch1);
    data_q = applyPreComp(imag(result),nn.Fs,21e9,Freq_ch2,1./IMResponse_ch2);

    awg.SendDataToAWG(data_i,1);
    awg.SendDataToAWG(data_q,2);
%     awg.SendDataToAWG(y1,1);
%     awg.SendDataToAWG(y2,2);

end

if 0
    % AWG发送信号
    awg.AWGSamplingRate = nn.Fs;
%     awg.SendDataToAWG(real(upSig),3);
    awg.SendDataToAWG(real(upSig),4);
end
if 1
for i=1:1
    Y = dso.readwaveform(3);
    pause(0.5);
    Z(:,i)=Y;
end
end
fs = 80e9; % sampling rate
fb = 64e9;
% load('CSPR_10dB.mat')
signal_dsb = Z(:,1);


%%
% resample to compensate for SFO
% f_offset = -0.5e6;
% tVec = 1/fs*(0:length(signal_dsb)-1);
% tVecNew = 0:1/(fs+f_offset):tVec(end);
% signal_orgin = interp1(tVec,signal_dsb,tVecNew,'spline');

% pwelch(signal_dsb)
signal_orgin=signal_dsb;
signal_orgin = LPF(signal_orgin,fs,22e9);


rxsig = real(signal_orgin(1:2*floor(length(signal_orgin)/2)));

% 误码率计算参数
Total=0;
Num=0;
% c_vec=0.02:0.001:0.03;
c_vec=0.000;
for i=1:length(c_vec)
    % c=0.07;%-11 0.08 -14 0.03 dither 为0.08
    c=c_vec(i);
    if 1
        fs_up=fs*2;
        Rxsig = KK_New(rxsig+c,fs,fs_up);
    else
        Rxsig=rxsig;
        fs_up=fs;
    end
    [DeWaveform,P,OptSampPhase,MaxCorrIndex] = Quick_Syn_Vec(Rxsig,label,1/fs_up,1/fb);
  x1=floor(P(1)/(nn.nPkts*1056));
  x2=floor((length(DeWaveform)-P(1))/(nn.nPkts*1056));
    x = x1+x2;
x=1;
    for idx=1:length(P)
        y=idx;
%         Data = DeWaveform(P(y)-nn.nPkts*1056*x1:P(y)+nn.nPkts*1056*x2-1);
        Data = DeWaveform(P(y):P(y)+nn.nPkts*1056*x-1);
        P_EST='none';
        pow='none';
        Sym_EST='symbol_est';%symbol_est
        f_EST='fre_est';
        nTrainSym = 50;
        W=nn.nModCarriers;
        nTrainCarrier=nn.nModCarriers;
         errSub = [5,8,13,16,21,125,157,253];
        Decode;
        EVM_Mea;
       
        % BER(i)=ber;
        Num=Num+num;
        Total=Total+a;
    end
end

BER=Num/Total;
fprintf('Total Num of Errors = %d, BER = %1.7f\n',Num,BER);
% save('CSPR_11dB.mat','Z','BER');