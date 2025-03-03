%% 参数定义
a=0;            %初始数据文件名最后的数字
% b=102;        %初始图像文件名最后的数字
ROP=-10;        %接收光功率
% alpha=0.1;    %滤波系数

%% 重命名文件,重复6次
%参数定义
% a=0;               %初始数据文件名最后的数字
% b=102;             %初始图像文件名最后的数字
%%示波器存储数据
instrreset;
visa_addr='TCPIP0::192.168.1.35::inst0::INSTR';
obj1 = visa('keysight', visa_addr);
set(obj1,'InputBufferSize', 80050);

fopen(obj1);
fwrite(obj1, '*IDN?');
data_recv = fscanf(obj1);
fprintf(1, '已连接示波器： %s\n', data_recv);
location='Data\';
filename1='aaa';
for i=1:1
    fwrite(obj1, "STO C2,FILE");
    pause(3)
    realName=strcat([location 'C2Trace00',num2str(a,'%03d'),'.csv']);
    changeName=strcat([location filename1 '_' num2str(ROP),'dBm-',num2str(i-1),'.csv']);
    readlist = dir(realName);
    if ~isempty(readlist)
        movefile(realName,changeName,'f');
    else
        disp('命名错误');
        break
    end
    a=a+1;
end
fclose(obj1);
% ROP=ROP-1;
ROP=ROP-1;
x=1;

%% 重命名文件,重复一次
%%示波器存储数据
instrreset;
visa_addr='TCPIP0::192.168.1.35::inst0::INSTR';
obj1 = visa('keysight', visa_addr);
set(obj1,'InputBufferSize', 80050);
fopen(obj1);
fwrite(obj1, '*IDN?');
data_recv = fscanf(obj1);
fprintf(1, '已连接示波器： %s\n', data_recv);
for i=1:1
    fwrite(obj1, "STO C2,FILE");
    pause(3)
    realName=strcat('D:\实验记录共享\实验数据\2023_09_18\data\matlab\C2Trace000',num2str(a,'%02d'),'.csv');
    % changeName=strcat('D:\实验记录共享\实验数据\2023_09_18\data\matlab\matlab_20GBaud_PAM4_PRBS15_upsam65_rrcos0.5_sps2_',num2str(ROP),'dBm.csv');
    changeName=strcat('D:\实验记录共享\实验数据\2023_11_09\data\keysight_20km\keysight_20GBaud_PAM4_PRBS15_upsam54_rrcos0.98_',num2str(ROP),'dBm.csv');
    readlist = dir(realName);
    if ~isempty(readlist)
        movefile(realName,changeName,'f');
    else
        disp('命名错误');
        break
    end
    a=a+1;
    ROP=ROP-3;
end
fclose(obj1);

%% figure重命名
folder = 'D:\实验记录共享\实验数据\2023_09_11\figure\';
files = dir([folder '*.jpg']);
for i = 1 : length(files)
    %读取一张图片（注意，该方法读取数据并不是按照顺序读取的）
    oldname = files(i).name;
    I = imread(strcat(folder,oldname));
    %将命名后的图片存放到F:\ICDAR\TestCutWord\NegativeSample\NewName\文件夹中
    imwrite(I,strcat('D:\实验记录共享\实验数据\2023_09_11\figure\matlab_10GBaud_PAM4_PRBS15_upsam65_rrcos0.4_sps4_',num2str(ROP),'dBm.jpg'));
    delete(strcat('D:\实验记录共享\实验数据\2023_09_11\figure\Lecory',num2str(b,'%d'),'.jpg'))
end

%% figure重命名
for j=1
    realName=strcat('D:\实验记录共享\实验数据\2023_09_11\figure\Lecory',num2str(b,'%d'),'.jpg');
    changeName=strcat('D:\实验记录共享\实验数据\2023_09_11\figure\matlab_10GBaud_PAM4_PRBS15_upsam65_rrcos0.4_sps4_',num2str(ROP),'dBm.jpg');
    readlist = dir(realName);
    if ~isempty(readlist)
    else
        disp('命名错误');
        break
    end
end

ROP=ROP-1;
b=b+1;

%% 连接OSC
% clear A_C A_C_loc0 A_C_loc
% instrreset;
% visa_addr='TCPIP0::192.168.1.25::inst0::INSTR';
% obj1 = visa('NI', visa_addr);
% set(obj1,'InputBufferSize', 80050);
% fopen(obj1);
% fwrite(obj1, '*IDN?');
% data_id = fscanf(obj1);
% fprintf(1, '已连接示波器: %s\n', data_id);
% comb_n = (comb_start:comb_step:comb_start+comb_step*(comb_num-1));
% comb_freq = 2.99792458e17./comb_n;
% date0 = datestr(now,'mmdd');
% wsAttnn=[];A_C_logn=[];
% for osc_time0 = 1:osc_time
%     fwrite(obj1, "STO C2,FILE");
%     readstr = strcat('C2combined10000',num2str(osc_time0-1),'.csv');
%     writestr = strcat('Auto\C2_',date0,'_',num2str(osc_time0),'0.csv');
%     pause(5)
%     readlist = dir(readstr);
%     if ~isempty(readlist)
%         movefile(readstr,writestr,'f');
%     else
%         disp('命名错误');
%         break
%     end
%     data_read = csvread(writestr,5,1);
% end
% fclose(obj1);
%


% filename1='30km\50GBaud_PAM4_PRBS15_rrcos1.00_sps1_resample93.4_';
% % filename1='40km\pre-9FFE+3DFE_50GBaud_PAM4_PRBS15_rrcos1.00_sps1_resample93.4_';

