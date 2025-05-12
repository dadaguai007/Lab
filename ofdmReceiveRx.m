clc;clear;close all;
addpath('Tx and Rx\')
addpath('Output\')
addpath('Plot\')
addpath('Tool\')
addpath('DSP\')
addpath('Fncs\')
% 信号生成
ofdmGenerateTx;

% 装载数据保存模块
ds=DataSaver([], datapath,[]);
ds.createFolder();


load('pd_inpower.mat')
pre='ROP-';
pd_inpower=savedata;
% 对输入光功率近似，取整数值
power = sprintf('%.1f.mat', pd_inpower);
% 读取输入数据
title=strcat(pre,power);
load(title)


% 数据输入
signal_orgin = savedata;

% 发射机参数
ofdmPHY=nn;

% 接收机参数
Rx=DataProcessor( ...
    ofdmPHY,...              % 发射机参数
    80e9,...                 % 接收信号的采样率
    64e9,...                 % 接收信号的波特率
    2*80e9,...               % KK恢复算法的采样率
    [],...                   % 接收的光电流信号
    1,...                    % 选取第 x 段信号
    50,...                   %  训练序列长度
    ofdmPHY.nModCarriers,...             % 相噪估计——导频位置
    ofdmPHY.nModCarriers,...             % 频偏估计——导频数量，一般对全体载波进行估计
    qam_signal,...           % 调制信号参考矩阵
    label,...                % 同步参考信号
    'off',...                % 默认 关闭 CPE
    'off',...                 % 频偏补偿 默认 打开
    'on',...                 % 是否选取全部信号 或者 分段选取
    'off');                  % 是否选择光电流信号进行处理


% 创建参考解码序列
Rx.createReferenceSignal();
% 预先均衡
filteredData = Rx.preFilter(signal_orgin, 22e9);
% 装载光电流信号
Rx.signalPHY.photocurrentSignal =filteredData;
% KK算法
[Rxsig,Dc]=Rx.Preprocessed_signal(filteredData);
% 同步
[DataGroup,Index_P,selectedPortionTotal]=Rx.Synchronization(Rxsig);
% 训练序列
Rx.Nr.nTrainSym =  50*10;
% 均衡解码
[~,~,~,data_ofdm_Total] = Rx.OFDM_ExecuteDecoding(selectedPortionTotal);
% 比特判决
[ber,num,L]=Rx.Direcct_Cal_BER(data_ofdm_Total);

name='test';

ds.name=name;
ds.data=ber;
ds.saveToMat();
