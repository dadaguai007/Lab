addpath('Tool\')

% 文件存储路径
datapath='Output\20240519_ofdm_32G_SSB_BTB_ssb_200mv_10k';

% 装载数据保存模块
ds=DataSaver([], datapath,[]);
ds.createFolder();

% 实验流程
lab = LabControl( ...
    KEYSIGHT6004A(),  ...    % 是徳示波器
    LeCroyScope(), ...       % lecroy示波器
    EXFO_VOA(), ...          % EXFO
    EXFO_VOA_Rs232(), ...    % EXFO_RS232
    Keysight8163B(), ...     % 是徳功率计
    AnritsuMT9810B(), ...    % 安捷伦功率计
    KeysightAWG(), ...       % 是徳AWG
    AgilentDCA(), ...        % 眼图仪
    RSA5103A5106(), ...      % 电谱仪5106
    RSA5103A(), ...          % 电谱仪5103
    SPD3303X_1(), ...        % DC
    YokogawaOSA());          % 横河光谱仪


% prefix of file
prefix = 'ROP';
% VOA 初始化
outpow_min = -43;
outpow_max = -38;
att_step = 1;
att_vec=lab.preVOA(outpow_min,outpow_max,att_step);


for iAtt = 1:length(att_vec)

    % 运行采集步骤
    system_pd_inpower=lab.runVOA(iAtt);
    system_inpower(iAtt)=system_pd_inpower;
    % 查看PD入关功率是否稳定，并进行调节
    fprintf('输入功率是否稳定于5dBm，稳定后按任意键数据采集！\n');
    pause();

    Amp_power=lab.pmKeysightRead(2);
    fprintf('PD Input power = %1.2f\n',Amp_power);
    % 采集数据
    data=lab.dsoLeCroyGet(1);

    % generate file name
    filename = sprintf('%s-%1.1f.mat',prefix,system_inpower(iAtt));

    % 数据存储(及时存储)
    name=filename;
    ds.name=name;
    ds.data=data;
    ds.saveToMat();

end

% 数据存储
name1='pd_inpower';
ds.name=name1;
ds.data=system_inpower;
ds.saveToMat();
