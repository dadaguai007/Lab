clc;clear;close all;
rsa=RSA5103A5106('10.16.0.254');
% datapath = 'Data\20240604_muticore_XT';'192.168.138.10'
% if ~exist(datapath,'dir')
%     mkdir(datapath);
% end

span=1e8;
% rsa.Auto_Calibration_OFF;
% T=rsa.GET_Auto_Information;
% p=rsa.Auto_Calibration;
% rsa.SetSpectrumparam(1e9,span);
% f = waitbar(0,'Please wait...');
% num=90000;
[pow,nPoints] = rsa.Read_Spectrum_N9030A(1);
freq = rsa.Get_Freq_N9030A();

plot(freq,pow);

num=1;
while(1)
    [pow,nPoints] = rsa.Read_Spectrum_N9030A(1);
   
    if length(pow)==nPoints/4
        if isempty(pow)
            continue
        end
        Pow(num,:)=pow;
        pause(1);
        str=['采集中...第',num2str(num),'次'];
        waitbar((num-1)/num,f,str);
        num=num+1;
    else
        continue
    end
end


%% 存储
rowsPerBlock = 200;  % 每块的行数
colsPerBlock = size(Pow,2);  % 每块的列数
numBlocks = ceil(size(Pow, 1) / rowsPerBlock) * ceil(size(Pow, 2) / colsPerBlock);

for i = 1:numBlocks
    blockRowStart = floor((i-1) / (size(Pow, 2) / colsPerBlock)) * rowsPerBlock + 1;%处理行向量的索引值
    blockRowEnd = min(blockRowStart + rowsPerBlock - 1, size(Pow, 1));
    blockColStart = mod(i - 1, (size(Pow, 2) / colsPerBlock)) * colsPerBlock + 1;%处理列向量的索引值
    blockColEnd = min(blockColStart + colsPerBlock - 1, size(Pow, 2));
    
    block = Pow(blockRowStart:blockRowEnd, blockColStart:blockColEnd);
    
    % 保存块到文件
    index=num2str(i);
    dataname=strcat('block',index);
    save(sprintf('%s\\%s.mat',datapath,dataname), 'block');
end
save(sprintf('%s\\Frequence.mat',datapath), 'Fre')

%%
% % tic
% for i=1:num
% [Pow(i,:),nPoints] = rsa.Read_Spectrum(1);
% pause(1);
% str=['采集中...第',num2str(i),'次，进程为',num2str(100*i/num),'%'];
% waitbar(i/num,f,str);
% end
% % toc
% [Fre] = rsa.Get_Fre(span,nPoints);
% figure;
% plot(Fre,Pow(i,:))
%%
% L=double(Fre>59e6&Fre<61e6);

L=double(Fre==1550e6);

k=find(L>0);
% L1=double(Fre>139e6&Fre<141e6);
L1=double(Fre==1630e6);
k1=find(L1>0);
for i=1:num
y=Pow(i,:);

peak1(i)=max(y(k));
peak2(i)=max(y(k1));

end

figure(1)
plot(peak1,'r')
hold on
plot(peak2,'b')
legend('red-80M','blue-160M')

figure(2)
 [c,lags] = xcorr(peak1-mean(peak1),peak2-mean(peak2),'normalized');
plot(lags,c)