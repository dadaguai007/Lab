classdef MP1764C < Device
    
    properties
        NumErrThreshold = 10;
        MaxMeasurementTime = 20; % unit: second
        StableBERRatio = 0.01;
        NumTrialTimes = 100;
        ReliableMeasTimes = 3;
        SmallBERThreshold = 1e-10;
    end
    
    methods
        function obj = MP1764C(GPIB_addr)
            if nargin <1
                obj.GPIB_Addr = 9;
            else
                obj.GPIB_Addr = GPIB_addr;
            end
            obj.DeviceName = 'MP1764C Error Detector';
            obj.VISA_Vendor = 'agilent';
        end
        
        function er = Read_ber(obj)
            % read the instant BER
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('ER?');
            txt = query(obj.DevObj,cmd);
            er = str2double(txt(4:end));
            fclose(obj.DevObj);
        end
        
        function ec = Read_bec(obj)
            % read the instant error count
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('EC?');
            txt = query(obj.DevObj,cmd);
            ec = str2double(txt(4:end));
            fclose(obj.DevObj);
        end
        
        function Display_mode(obj,value)
            % 0 : ERROR RATIO
            % 1 : ERROR COUNT
            % 2 : ERROR INTERVAL
            % 3 : ERROR FREE INTERVAL
            % 4 : CLOCK FREQUENCY
            if nargin<1
                value = 0;
            end
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('DMS %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Measurement_mode(obj,value)
            % 0 : REPEAT
            % 1 : SINGLE
            % 2 : UNTIMED
            if nargin<1
                value = 2;
            end
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('MOD %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Measurement_pattern(obj,value)
            % 0 : ALTERNATE
            % 1 : DATA
            % 2 : ZEROSUBST
            % 3 : PRBS
            if nargin<1
                value = 3;
            end
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd=sprintf('PTS %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Set_PRBS(obj,value)
            % 2 : 2^7-1
            % 3 : 2^9-1
            % 5 : 2^11-1
            % 6 : 2^15-1
            % 7 : 2^20-1
            % 8 : 2^23-1
            % 9 : 2^31-1
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            fprintf(obj.DevObj,'*cls');
            query(obj.DevObj,'*opc?');
            cmd=sprintf('PTN %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Set_patternlogic(obj,value)
            % 0 : Positive
            % 1 : Negative
            if nargin<1
                value = 0;
            end
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd=sprintf('LGC %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Set_inputthreshold(obj,value)
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd=sprintf('DTH %f',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Set_inputdelay(obj,value)
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd=sprintf('CPA %d',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
        
        function Auto_search(obj,value)
            %             0 : Auto Search off
            %             1 : Auto Search on
            %             2 : Auto Search fail
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('SRH %d',value);
fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end

        function Set_threshold(obj,value)
            % Range of numeric values: 
            % Max. 1.875
            % Min. -3.000
            % Step 0.001
            obj.Auto_search(0);
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd=sprintf('DTH %f',value);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end

        function [BER,th_vec] = Sweep_Threshold_BER(obj,th_min1,th_max1,th_min2,th_max2,step)
%             if nargin < 2
%                 th_min = -1;
%                 th_max = 1;
%                 step = 0.01;
%             end
            th_vec = [th_min1:step:th_max1 th_min2:step:th_max2];
            obj.DevObj = obj.Init();
            fopen(obj.DevObj); 
            for ith = 1:length(th_vec)
                % volt_th = th_vec(ith);
                % set voltage
                obj.Set_threshold(th_vec(ith));
                %pause(0.2);
                %read
                BER(ith) = obj.Read_ber_reliable();
%                 if BER(ith) == 0
%                     ith = ith+floor(length(th_vec)/5);
%                     
%                 end
                % output
                % fprintf('volt_th = %1.3f v, BER = %1.10f\n',th_vec(ith),BER(ith));
            end
            % save('Optimal_threshold.mat','th_vec','BER');
            % plot(th_vec,BER);
            fclose(obj.DevObj);
        end
        
        function clock = Check_clock_loss(obj)
            %             0 : Not clock loss status
            %             1 : Clock loss status
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('CLI?');
            txt1 = query(obj.DevObj,cmd);
            clock = str2double(txt1(4:end));
            fclose(obj.DevObj);
        end
        
        function sync = Check_sync_loss(obj)
            %             0 : Not synk loss status
            %             1 : synk loss status
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('SLI?');
            txt1 = query(obj.DevObj,cmd);
            sync = str2double(txt1(4:end));
            fclose(obj.DevObj);
        end
        
        function cur = Current_data(obj)
            % check if current data is on or off
            %             0 : off
            %             1 : on
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
            cmd = sprintf('CUR?');
            txt1 = query(obj.DevObj,cmd);
            cur = str2double(txt1(4:end));
            fclose(obj.DevObj);
        end
        
        function Prexamine(obj)
            % check clock status
            clock = obj.Check_clock_loss;
            if clock == 1
                error('clock loss');
            end
            % check sync status
            sync = obj.Check_sync_loss;
            if sync == 1
                error('sync loss');
            end
            % check if current data button is on
            cur = obj.Current_data;
            if cur == 0
                error('Current Data not open');
            end
        end
        
        function ClearBERMeasurement(obj,clearMethod)
            if nargin < 2
                clearMethod = 'ChangePRBS';
            end
            
            switch lower(clearMethod)
                case 'changeprbs'
                    obj.Set_PRBS(7);
                    obj.Set_PRBS(6);
                case 'changemeasurementmode'
                    obj.Measurement_mode(0);
                    pause(0.2);
                    obj.Measurement_mode(2);
            end
        end
        
        function [ber,info] = Read_ber_reliable(obj)
            info = 0;
            % clear BER measurement
            obj.ClearBERMeasurement();
            % start
            Init_ber = obj.Read_ber;
            if Init_ber > obj.SmallBERThreshold % % large BER case
                ber1 = Init_ber;
                ber2 = obj.Read_ber;
                n=0;
                for j = 1:obj.NumTrialTimes
                    rela_error = abs((ber1-ber2)/ber2);
                    if rela_error < obj.StableBERRatio
                        n = n+1;
                        if n == obj.ReliableMeasTimes
                            n = 0;
                            break;
                        else
                            ber1 = ber2;
                            ber2 = obj.Read_ber;
                            continue;
                        end
                    else
                        n = 0;
                        ber1 = ber2;
                        ber2 = obj.Read_ber;
                        continue;
                    end
                end
                if j == 100
                    fprintf('BER is unstable\n');
                end
            else % small BER case
                time = 0;
                tic;
                while time <= obj.MaxMeasurementTime
                    pause(1);
                    count = obj.Read_bec;
                    if count > obj.NumErrThreshold
                        break;
                    else
                        time = toc;
                        continue;
                    end
                end
                if time > obj.MaxMeasurementTime
                    info = 1;
                    fprintf('Timeout.The number of bit errors is less than  %d\n',...
                        obj.NumErrThreshold);
                end
            end
            % now we can read the current BER reliably
            ber = obj.Read_ber;
        end
        
        function PRBS_error_test(obj)
            for i = 1:200
                obj.DevObj = obj.Init();
                fopen(obj.DevObj);
                cmd = sprintf('PTN %d',5);
                fprintf(obj.DevObj,cmd);
                txt = query(obj.DevObj,'PTN?');
                id1 = str2double(txt(5));
                cmd = sprintf('PTN %d',6);
                fprintf(obj.DevObj,cmd);
                txt = query(obj.DevObj,'PTN?');
                id2 = str2double(txt(5));
                % check if successful
                if id1 == id2
                    m(i) = 1; % switch unsuccessful
                else
                    m(i) = 0; % switch successful
                end
                fclose(obj.DevObj);
            end
        end
        
    end
end