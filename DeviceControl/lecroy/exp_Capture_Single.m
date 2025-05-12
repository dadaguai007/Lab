clear;close all;

addpath('LeCroyDSO');

% Create and config DSO object
ipaddr = '192.168.1.35';
dso = LeCroyScope(ipaddr);
dso.ChannelConfig = [2];
dso.SamplingRate = 80e9;
dso.Memory = 2e6;
% 
% filename = 'Data\obtb.mat';
% filename = 'Data\dml_w_pre.mat';
filename = 'Data\2.mat';

% Capture once
data = dso.Capture(filename); % capture with savinge