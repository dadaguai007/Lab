function timerCallback1(~, ~)
% 用于调用光功率计，按等时间间隔进行控制指标的探测
% 全局变量，用于计数
global counter;
global error_level;
global L1;
global L2;
% 每次触发计数器加1
counter = counter + 1;
ipaddr = '172.16.104.66';
osa = YokogawaOSA(ipaddr);
%读取光谱的抑制比
for jj=1:3
    osa.Single();
    [wavelength,waveform] = osa.GetOSATrace();
    wave(:,jj)=waveform;
    pause(0.5)
end
m_wave=mean(wave,2);
peak_level = m_wave(L1);
restrain_level = m_wave(L2);
error_level(counter) = peak_level - restrain_level;
osa.Repeat();
fprintf('ossr读数：%1.3f\n',error_level(counter));