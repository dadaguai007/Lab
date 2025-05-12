classdef LabControl < handle

    properties
        %         Nr%无量纲参数
        Implementation;% 参考信号实施参数
        %         Button; % 开关讯号

    end


    methods

        function obj = LabControl(varargin)
            if numel(varargin) == 12
                obj.Implementation.dsoKeysight =  varargin{1};  % 是徳示波器
                obj.Implementation.dsoLeCroy   =  varargin{2};  % lecroy示波器
                obj.Implementation.voa         =  varargin{3};  % EXFO
                obj.Implementation.voaRs232    =  varargin{4};  % EXFO_Rs232
                obj.Implementation.pmKeysight  =  varargin{5};  % 是徳功率计
                obj.Implementation.pmAnritsuMT =  varargin{6};  % 安捷伦功率计
                obj.Implementation.awg         =  varargin{7};  % 是徳AWG
                obj.Implementation.dca         =  varargin{8};  % 眼图仪
                obj.Implementation.rsa5106     =  varargin{9};  % 电谱仪5106
                obj.Implementation.rsa5103     =  varargin{10};  % 电谱仪5103
                obj.Implementation.Dc          =  varargin{11}; % DC
                obj.Implementation.osa         =  varargin{12}; % 横河光谱仪
            end
        end

        % 功率计校准
        function pmKeysightAutoCalibration(obj)
            CaliChNo=2;
            RefChNo=1;
            obj.Implementation.pmKeysight.AutoCalibration(CaliChNo,RefChNo);
        end

        % 示波器抓取数据
        function data=dsoKeysightGet(obj,idx)
            data= obj.Implementation.dsoKeysight.readwaveform(idx);
        end

        % 示波器抓取数据
        function data=dsoLeCroyGet(obj,idx)
            obj.Implementation.dsoLeCroydso.ChannelConfig = idx;
            obj.Implementation.dsoLeCroydso.SamplingRate = 80e9;
            obj.Implementation.dsoLeCroydso.Memory = 2e6;
            data = obj.Implementation.dsoLeCroy.Capture();
        end

        % AWG发送信号
        function awgSendData(obj,upSig,fs,delay_ps,chidx)
            % 纠正延时
            %delay_ps=-1;
            result = iqdelay(upSig, fs, delay_ps*1e-12).';
            % AWG发送信号
            obj.Implementation.awg.AWGSamplingRate = fs;

            obj.Implementation.awg.SendDataToAWG(real(result),chidx(1));
            obj.Implementation.awg.SendDataToAWG(imag(result),chidx(2));
        end

        % AWG的自适应纠正
        function  [resp1,resp2,resp3,resp4]=awgCalibration(obj)
            resp1 = obj.Implementation.awg.Query_Calibration(1,0.5);
            resp2 = obj.Implementation.awg.Query_Calibration(2,0.5);
            resp3 = obj.Implementation.awg.Query_Calibration(3,0.5);
            resp4 = obj.Implementation.awg.Query_Calibration(4,0.5);
            %save('Data\AWG_response.mat','resp1','resp2','resp3','resp4');
        end
        
        % 加上信道补偿的信号发射
        function  awgPreComp(obj,upSig,fs,delay_ps,freEnd,chidx,resp1,resp2,resp3,resp4)
            % load('AWG_response.mat');
            % 纠正延时
            %delay_ps=-1;
            result = iqdelay(upSig, fs, delay_ps*1e-12).';
            % AWG发送信号
            obj.Implementation.awg.AWGSamplingRate = fs;
            % 信道响应
            Freq_ch1 = resp1(:,1);
            IMResponse_ch1 = resp1(:,2).*exp(1j*resp1(:,3));
            Freq_ch2 = resp2(:,1);
            IMResponse_ch2 = resp2(:,2).*exp(1j*resp2(:,3));
            Freq_ch3 = resp3(:,1);
            IMResponse_ch3 = resp3(:,2).*exp(1j*resp3(:,3));
            Freq_ch4 = resp4(:,1);
            IMResponse_ch4 = resp4(:,2).*exp(1j*resp4(:,3));

            % 补偿
            %freEnd=21e9;
            if      chidx(1) == 1
                data_i = applyPreComp(real(result),fs,freEnd,Freq_ch1,1./IMResponse_ch1);
                data_q = applyPreComp(imag(result),fs,freEnd,Freq_ch2,1./IMResponse_ch2);
            elseif chidx(1) == 3
                data_i = applyPreComp(real(result),fs,freEnd,Freq_ch3,1./IMResponse_ch3);
                data_q = applyPreComp(imag(result),fs,freEnd,Freq_ch4,1./IMResponse_ch4);
            end
            % 信号发送
            obj.Implementation.SendDataToAWG(data_i,chidx(1));
            obj.Implementation.SendDataToAWG(data_q,chidx(1));
        end

        % 功率计读数
        function Amp_power=pmKeysightRead(obj,idx)
            Amp_power = obj.Implementation.pmKeysight.Read_Power(1,idx);
        end

        function  Amp_power=pmAnritsuMTRead(obj,idx)
            Amp_power=obj.Implementation.pmAnritsuMT.Read_Power(idx);
        end


        % VOA 初始化
        function att_vec=preVOA(~,outpow_min,outpow_max,att_step)

            %outpow_min = -43;  % 衰减最大小
            %outpow_max = -38;  % 衰减最大值
            att_start = script_set_initatt(outpow_min,1);% 衰减值得初始值，一般设置为最大光功率，后续是衰减递增
            %att_step = 1; % 衰减步长
            nAtt = outpow_max-outpow_min+1;
            % 减法代表：最低——最高的过程
            att_vec = att_start - att_step*(0:nAtt-1);% 减法或者加法
        end


        % VOA运行
        function system_pd_inpower=runVOA(obj,att_vec)
            % set attenuation
            att_curr = att_vec;
            % 设置衰减值
            obj.Implementation.voa.Set_Att_Directly(att_curr);

            % EDFA输入功率（真实系统的输入）
            system_pd_inpower=obj.pmKeysightRead(1);
            % display the input
            fprintf('EDFA Input power = %1.2f\n',system_pd_inpower);

            % PD输入功率
            Amp_power=obj.pmKeysightRead(2);
            Input_power=Amp_power;
            fprintf('PD Input power = %1.2f\n',Input_power);

            % 展示PD输入功率，并提醒
            if floor(Input_power)==5
                sound(sin(2*pi*25*(1:4000)/100));
            else
                fprintf('注意调节光功率！\n');
            end
        end

        % 获取CSPR
        function  GetOneMeasurement_CSPR_byDCA(obj,caliStd)

            obj.Implementation.dca.ConnectionType = 'GPIB';
            obj.Implementation.dca.GPIB_Addr = 7;

            % read the DCA
            dcaInfo = obj.Implementation.GetHistogramInfo;

            % Estimate by DCA
            % estCSPR = 10*log10(calc_cspr_dca(dcaInfo.mean,dcaInfo.std));
            estCSPR = 10*log10(calc_cspr_dca_cali(dcaInfo.mean,dcaInfo.std,caliStd));

            % display the information
            fprintf('Exp log >> estCSPR = %1.1f dB.\n',estCSPR);

        end

        % 测底噪
        function [caliMean,caliStd]=MeasureChNoSigForCali_byDCA(obj)
            obj.Implementation.dca.ConnectionType = 'GPIB';
            obj.Implementation.dca.GPIB_Addr = 7;

            % read the DCA
            dcaInfo = obj.Implementation.GetHistogramInfo;

            % save info
            caliMean = dcaInfo.mean;
            caliStd = dcaInfo.std;
            % save('Data\DCA_Calibration.mat','caliStd','caliMean');
        end

        % 光谱仪标点
        function [L1,L2]=SetMarker_bySpec(obj)

            A_1=input('输入边带峰值： \n');
            A_2=input('输入抑制边带峰值： \n');
            obj.Implementation.osa .SetMarker(2,A_1);%mark2 design higher
            obj.Implementation.osa .SetMarker(1,A_2);%mark1 design lower
            %确认两个峰值点的vector position
            obj.Implementation.osa.Single();
            % 获取信号
            [wavelength,~] = obj.getOpticalTrance();
            format long
            a_1 = A_1*(10^-9);
            a_2 = A_2*(10^-9);
            L1=find(abs(wavelength-a_1)<1e-15);
            L2=find(abs(wavelength-a_2)<1e-15);
            fprintf('L1 value  is %1.3f\n',L1);
            fprintf('L2 value  is %1.3f\n',L2);
            obj.Implementation.osa.Repeat();
        end


        function [wavelength,waveform]=getOpticalTrance(obj)
            [wavelength,waveform] = obj.Implementation.osa.GetOSATrace();
        end

        % 获取OSSR
        function error_level=getOssr_bySpec(obj,L1,L2)
            obj.Implementation.osa.Single();
            % 获取信号
            [~,waveform]= obj.getOpticalTrance();
            peak_level = waveform(L1);
            restrain_level = waveform(L2);
            error_level = peak_level - restrain_level;
            obj.Implementation.osa.Repeat();
            fprintf('ossr读数：%1.3f\n',error_level);
        end

    end

end
