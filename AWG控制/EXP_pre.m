clc;clear;close all;
load('AWG_response.mat');
Freq_ch1 = resp1(:,1);
IMResponse_ch1 = resp1(:,2);
PHResponse_ch1 = resp1(:,3);
x2 = 0.5e6:0.5e6:32e9;
vq1 = interp1(Freq_ch1,IMResponse_ch1,x2,'spline');
IMResponse_ch1_1 = vq1';

x2 = 0.5e6:0.5e6:32e9;
vq2 = interp1(Freq_ch1,PHResponse_ch1,x2,'spline');
PHResponse_ch1_1 = vq2';

Freq_ch2 = resp2(:,1);
IMResponse_ch2 = resp2(:,2);
PHResponse_ch2 = resp2(:,3);

vq3 = interp1(Freq_ch2,IMResponse_ch2,x2,'spline');
IMResponse_ch2_1 = vq3';

vq4 = interp1(Freq_ch2,PHResponse_ch2,x2,'spline');
PHResponse_ch2_1 = vq4';



Hf_IM1 = [0;IMResponse_ch1_1];
for i = 1:1:320
    Hf_IM_1(i,:)= Hf_IM1((i-1)*125+1,:);
end

Hf_IM2 = [0;IMResponse_ch2_1];
for i = 1:1:320
    Hf_IM_2(i,:)= Hf_IM2((i-1)*125+1,:);
end

Hf_PH1 = [0;PHResponse_ch1_1];
for i = 1:1:320
    Hf_PH_1(i,:)= Hf_PH1((i-1)*125+1,:);
end

Hf_PH2 = [0;PHResponse_ch2_1];
for i = 1:1:320
    Hf_PH_2(i,:)= Hf_PH2((i-1)*125+1,:);
end


Hf_IM_pre1 =(1./(Hf_IM_1));
Hf_IM_pre1(1) = 1;
Hf_IM_pre2 = (1./Hf_IM_2);
Hf_IM_pre2(1) = 1;
Hf_PH_pre1 = 1./exp(Hf_PH_1);%exp(Hf_DML_PH1)
Hf_PH_pre2 = 1./exp(Hf_PH_2);%exp(Hf_EAM_PH1)
% Hf_1 = Hf_IM_pre1.*Hf_PH_pre1;
% Hf_2 = Hf_IM_pre2.*Hf_PH_pre2;
Hf_1 = Hf_IM_pre1;
Hf_2 = Hf_IM_pre2;