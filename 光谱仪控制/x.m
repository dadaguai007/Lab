clear;clc;
global counter;
global error_level;
global L1;
global L2;
ipaddr = '172.16.104.66';
osa = YokogawaOSA(ipaddr);
A_1=input('输入边带峰值： \n');
A_2=input('输入抑制边带峰值： \n');
osa.SetMarker(2,A_1);%mark2 design higher
osa.SetMarker(1,A_2);%mark1 design lower
%确认两个峰值点的vector position
osa.Single();
[wavelength,waveform] = osa.GetOSATrace();
format long
a_1 = A_1*(10^-9);
a_2 = A_2*(10^-9);
L1=find(abs(wavelength-a_1)<1e-15);
L2=find(abs(wavelength-a_2)<1e-15);
fprintf('L1 value  is %1.3f\n',L1);
fprintf('L2 value  is %1.3f\n',L2);
osa.Repeat();

counter=0;
error_level=[];
%创建一个timer对象，设置定时器的执行函数和时间间隔
t = timer('ExecutionMode', 'fixedRate', 'Period',60, 'TimerFcn', @timerCallback1);
% 启动定时器
start(t);
pause(2000);
stop(t);
delete(t);
figure;
plot(1:counter,error_level)