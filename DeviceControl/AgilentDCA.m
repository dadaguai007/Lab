classdef AgilentDCA < Device
    methods
        function obj = AgilentDCA(GPIB_Addr)
            if nargin <1
                obj.GPIB_Addr = 7;
            else
                obj.GPIB_Addr = GPIB_Addr;
            end
            obj.DeviceName = 'Agilent 86100B DCA';
            obj.VISA_Vendor = 'Agilent';
            obj.DevObj = obj.Init();
            % set the buffer size
            obj.DevObj.InputBufferSize = 1e6;
            obj.DevObj.OutputBufferSize = 1e6;
            flushoutput(obj.DevObj);
            flushinput(obj.DevObj);
        end
        
        function [Waveform] = Read_Waveform(obj,channel,n_avg)
            if nargin < 2
                n_avg = 1;
            end
            obj.DevObj = obj.Init();
            % set the buffer size
            obj.DevObj.InputBufferSize = 1e6;
            obj.DevObj.OutputBufferSize = 1e6;
            flushoutput(obj.DevObj);
            flushinput(obj.DevObj);
            % read the waveform
            % open the connection
            fopen(obj.DevObj);
            % set the data source to Channel
            fprintf(obj.DevObj,sprintf(':waveform:source channel%d',channel));
            % get the data
            for idx = 1:n_avg
                fprintf(obj.DevObj,':sing');
                fprintf(obj.DevObj,':wav:data?');
                waveform_txt = fscanf(obj.DevObj,'%s');
                wf_temp = textscan(waveform_txt,'%f','delimiter',',').';
                wf(idx,:) = wf_temp{1};
                pause(0.1);
            end
            if n_avg ~= 1
                wf = mean(wf);
            end
            Waveform.Waveform = wf;
            % get the time scale
            Waveform.scale = str2double(query(obj.DevObj,':tim:scal?'));
            Waveform.delay = str2double(query(obj.DevObj,':tim:pos?'));
            Waveform.t = Waveform.scale*(0:length(wf)-1);
            Waveform.XUnit = query(obj.DevObj,':waveform:xunits?');
            Waveform.YUnit = query(obj.DevObj,':waveform:yunits?');
            fprintf(obj.DevObj,':run');
            fclose(obj.DevObj);
        end

        function SaveJPGImage(obj,filename,folder)
            % save the screen image to the DCA
            if nargin < 3
                folder = [];
                fprintf('Save the default folder since no folder is specified.\n');
            end
            g = obj.Init();
            fopen(g);
            % check if folder is specified
            if isempty(folder)
                cmd = sprintf(':DISK:SIMage "%s.jpg"',filename);
                fprintf(g,cmd);
            else
                % cd into the "screen images" folder
                fprintf(g,':DISK:CDIR "C:\User files\screen images"');
                % create folder
                cmd = sprintf(':DISK:MDIR "%s"',folder);
                fprintf(g,cmd);
                % cd into the new folder
                cmd = sprintf(':DISK:CDIR "C:\\User files\\screen images\\%s"',folder);
                fprintf(g,cmd);
                % write screen image
                cmd = sprintf(':DISK:SIMage ".\\%s\\%s.jpg"',folder,filename);
                fprintf(g,cmd);
            end
            fclose(g);
        end
        
        function Vrms = MeasureRMS(obj,chID)
            obj.DevObj = obj.Init();
            % clear
            obj.Set(':CDISplay');
            % run
            obj.Set(':run');
            % pause
            pause(1);
            % read
            g = obj.Init();
            fopen(g);
            fprintf(g,':SYSTEM:HEADER OFF'); % to disable the header of return
            cmd = sprintf(':MEASURE:VRMS? DISP,AC, CHAN%d',chID);
            txt = query(g,cmd);
            Vrms = str2double(txt);
            fclose(g);
        end

        function SetSystemMode(obj,modeStr)
            % modeStr: EYE | OSCilloscope | TDR | JITTer
            g = obj.Init();
            fopen(g);
            cmd = [':SYSTem:MODE ',modeStr];
            fprintf(g,cmd);
            fclose(g);
        end
        
        function SetTimebaseRange(obj,range)
            % Note: the unit of range is 100 ms
            g = obj.Init();
            fopen(g);
            cmd = sprintf('TIMEBASE:RANGE %f',range);
            fprintf(g,cmd);
            fclose(g);
        end

        function AutoSetVerticalScale(obj,ch)
           g = obj.Init();
           fopen(g);
           % switch to eye/mask mode
           fprintf(g,':SYSTem:MODE OSC');
           % clear the display
           fprintf(g,':CDISplay');
           % run
           fprintf(g,':run');
           % set vertical scale to a large number
           vs_large = 10e-3;
           cmd = sprintf(':CHANNEL%d:SCALE %1.3f',ch,vs_large);
           fprintf(g,cmd);
           % get and compensate v_average
           cmd = sprintf(':CHANNEL%d:OFFSET?',ch);
           txt = query(g,cmd);
           offset = str2double(txt);
           cmd = sprintf(':MEASURE:VTOP? CHANnel%d',ch);
           txt = query(g,cmd);
           v_top = str2double(txt);
           cmd = sprintf(':MEASURE:VBASE? CHANnel%d',ch);
           txt = query(g,cmd);
           v_base = str2double(txt);
           offset_new = offset + (v_top-v_base)/2;
           cmd = sprintf(':CHANNEL%d:OFFSET %1.3f',ch,offset_new);
           fprintf(g,cmd);
           % get current max. and mean vpp
           cmd = sprintf(':MEASure:VAMPlitude? CHAN%d',ch);
           txt = query(g,cmd);
           vs_curr = str2double(txt);
           % set new
           margin = 0.3;
           vs_new = vs_curr*(1+margin)/8;
           cmd = sprintf(':CHANNEL%d:SCALE %1.3f',ch,vs_new);
           fprintf(g,cmd);

           cmd = sprintf(':CHANNEL%d:OFFSET %1.3f',ch,5e-3);
           fprintf(g,cmd);

%                       % get and compensate v_average
%            cmd = sprintf(':CHANNEL%d:OFFSET?',ch);
%            txt = query(g,cmd);
%            offset = str2double(txt);
%            cmd = sprintf(':MEASURE:VTOP? CHANnel%d',ch);
%            txt = query(g,cmd);
%            v_top = str2double(txt);
%            cmd = sprintf(':MEASURE:VAVerage? DISPLAY, CHANnel%d',ch);
%            txt = query(g,cmd);
%            v_avg = str2double(txt);
%            offset_new = offset - v_avg;
%            fprintf(g,cmd);

           % close
           fclose(g);
        end

        function SetChanNtoMemoryAndDisplay(obj,data_ch,mem_ch)
            if nargin < 3
                mem_ch = 1;
            end
            g = obj.Init();
            fopen(g);
            % save the waveform of channel #ch to memory 1
            cmd = sprintf(':WMEMORY%d:SAVE chan%d',mem_ch,data_ch);
            fprintf(g,cmd);
            % turn on the display
            cmd = sprintf(':WMEMORY%d:DISPlay ON',mem_ch);
            fprintf(g,cmd);
            fclose(g);
        end

        function SetMemoryOnOff(obj,mem_ch,state)
            if nargin < 3
                mem_ch = 1;
                state = 1;
            end
            % mem_ch: memory channel id
            % state: ON/OFF --> 1/0
            g = obj.Init();
            fopen(g);
            % turn on/off the display
            cmd = sprintf(':WMEMORY%d:DISPlay %d',mem_ch,state);
            fprintf(g,cmd);
            fclose(g);
        end

        function [snr,height] = MeasureSNR(obj,nMeasTimes)
            if nargin < 2
                nMeasTimes = [];
            end

            g = obj.Init();
            fopen(g);
            % switch to eye/mask mode
            fprintf(g,':SYSTem:MODE EYE');
            % clear the display
            fprintf(g,':CDISplay');
            % run
            fprintf(g,':run');
%             pause(10);
            % make sure nMeasTimes measurements are performed
            if ~isempty(nMeasTimes)
                currMeasTimes = 0;
                while currMeasTimes < nMeasTimes
                    pause(3);
                    [~,item] = obj.GetMeasurementResults('Eye S/N(2)');
                    currMeasTimes = item.nsamples;
                    disp(num2str(currMeasTimes));
                end
                fopen(g);
                fprintf(g,':stop');
                
            end
            % measure the snr of the current display
            txt = query(g,':MEASURE:CGRADE:ESN?');
            snr = str2double(txt);
            txt = query(g,':MEASure:CGRade:EHEight?');
            height = str2double(txt);
            fclose(g);
        end
       
        function [results,item] = GetMeasurementResults(obj,ItemName)
            % read back the measurement results in the right-bottom corner
            % of DCA during the measurement
            % ItemName: the name of item that is of interest
            % 
            % added on 2023/02/20
            if nargin < 2
                ItemName = [];
                item = [];
            end
            g = obj.Init();
            fopen(g);
            txt = query(g,':MEASure:RESults?');
            txtArray = reshape(split(txt(1:end-1),','),7,[]).';
            for idx = 1:size(txtArray,1)
                results{idx}.ItemName = txtArray{idx,1};
                results{idx}.current = str2double(txtArray{idx,2});
                results{idx}.min = str2double(txtArray{idx,3});
                results{idx}.max = str2double(txtArray{idx,4});
                results{idx}.mean = str2double(txtArray{idx,5});
                results{idx}.std = str2double(txtArray{idx,6});
                results{idx}.nsamples = str2double(txtArray{idx,7});
                % search for the item of interest
                if ~isempty(ItemName)
                    if strcmpi(results{idx}.ItemName,ItemName)
                        item = results{idx};
                    end
                end
            end
            fclose(g);
        end
       
       function height = MeasureEYEHeight(obj)
           g = obj.Init();
           fopen(g);
           % switch to eye/mask mode
           fprintf(g,':SYSTem:MODE EYE');
           % clear the display
           fprintf(g,':CDISplay');
           % run
           fprintf(g,':run');
           pause(3);
           % measure the snr of the current display
           txt = query(g,':MEASure:CGRade:EHEight?');
           height = str2double(txt);
           fclose(g);
        end
        
        function histInfo = GetHistogramInfo(obj)
            obj.DevObj = obj.Init();
%             % open the connection
%             fopen(obj.DevObj);
            % clear
            obj.Set(':CDISplay');
            % run
            obj.Set(':run');
            % make sure the number of hits should be larger than 100k
            nHits = 0;
            while(nHits<100e3)
                pause(0.1);
                txt = obj.Read(':MEASure:HISTogram:HITS?');
                nHits = str2double(txt);
            end
            histInfo.nHits = nHits;
            % stop
            obj.Set(':stop');
            % read the histogram information
            histInfo.mean = obj.ReadFloat(':MEASure:HISTogram:MEAN?');
            histInfo.std = obj.ReadFloat(':MEASure:HISTogram:STDDev?');
            histInfo.median = obj.ReadFloat(':MEASure:HISTogram:MEDian?');
            histInfo.m1 = obj.ReadFloat(':MEASure:HISTogram:M1S?');
            histInfo.m2 = obj.ReadFloat(':MEASure:HISTogram:M2S?');
            histInfo.m3 = obj.ReadFloat(':MEASure:HISTogram:M3S?');
            % calculate the cspr
            histInfo.cspr = 10*log10((histInfo.mean)/histInfo.std);
            % run
            obj.Set(':run');
%             % close the connection
%             fclose(obj.DevObj);
            % 
        end
    end
end