clear; close all;clc;
% 控制VOA调整输入光功率，并读取进入PD输入光功率，手动调节功率为恒定值
voa = EXFO_VOA();
pm = Keysight8163B();
dso = KEYSIGHT6004A();
% channels to be captured
chIDs = 3;
% data path
datapath = 'Data\20240519_ofdm_32G_SSB_BTB_ssb_200mv_10k';
if ~exist(datapath,'dir')
    mkdir(datapath);
end
% prefix of file
prefix = 'ROP';

%
outpow_min = -43;
outpow_max = -38;
att_start = script_set_initatt(outpow_min,1);% 衰减值得初始值，一般设置为最大光功率，后续是衰减递增
att_step = 1;
nAtt = outpow_max-outpow_min+1;
% 减法代表：最低——最高的过程
att_vec = att_start - att_step*(0:nAtt-1);% 减法或者加法

for iAtt = 1:length(att_vec)
    VOA_Run;
    % 查看PD入关功率是否稳定，并进行调节
    fprintf('输入功率是否稳定于5dBm，稳定后按任意键数据采集！\n');
    pause();
    Get_inpower;
    DSO_Get;
end

save(sprintf('%s\\pd_inpower.mat',datapath),'pd_inpower');