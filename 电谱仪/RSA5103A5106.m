classdef RSA5103A5106 < Device5106

    properties (Dependent = true)

    end

    methods
        function obj = RSA5103A5106(addr)
            % addr: address, could be number (for GPIB) or string (for TCP)
            if nargin <1
                addr = 20;
            end
            obj.Addr = addr;
            % determine the address type and connection method
            if ischar(addr)
                obj.ConnectionType = 'TCPIP';
            elseif isa(addr,'double')
                obj.ConnectionType = 'GPIB';
            else
                error('Please input correct address!');
            end
            % set device name
            obj.DeviceName = 'Tektronix 5103A Real-time Signal Analyzer';
            obj.VISA_Vendor = 'agilent';

        end

        function SetSpectrumparam(obj,center,span)
            % center  and span is the double
            dev = obj.Init();
            fopen(dev);

            fprintf(dev, ...
                sprintf('SENSe:SPECtrum:FREQuency:CENTer %dGHz',...
                center));
            fprintf(dev, ...
                sprintf('SENSe:SPECtrum:FREQuency:SPAN %dkHz',...
                span));
            fclose(dev);
        end

        function [pow,nPoints] = Read_Spectrum_N9030A(obj,channel)
            g = obj.Init();
            g.InputBufferSize = 1e6;
            g.OutputBufferSize = 1e6;
            fopen(g);
            cmd = sprintf('TRACe%d:DATA? TRACE%d',channel,channel); 
            txt = query(g,cmd);
            % convert the data text to float numbers
            data = textscan(txt,'%f','Delimiter',',');
            pow = data{1};
            nPoints = length(pow);
            fclose(g);
        end

        function [pow,nPoints] = Read_Spectrum(obj,channel)
            g = obj.Init();
            g.InputBufferSize = 1e6;
            g.OutputBufferSize = 1e6;
            fopen(g);
%             fprintf(g,'INITiate:CONTinuous OFF;INITiate:IMMediate');
%             fprintf(g,'ABORT');

%             cmd = sprintf('READ:SPECtrum:Trace%d?',channel);
            cmd = sprintf('TRACe%d:DATA? TRACE%d',channel,channel); 
            fprintf(g,cmd);
%             get_txt = query(g,sprintf(':READ:OBWidth%d? ',channel));
%             a = sscanf(get_txt,'%f');
            % discard first 6 digits
            a = fread(g);
            nPoints = str2double(strjoin(cellstr(char(a(3:end))),''));
            % now read the data of 4 bytes in little endian order
            pow = fread(g,nPoints/4,'float');
            fclose(g);
        end

        function freq = Get_Freq_N9030A(obj)
            g = obj.Init();
            fopen(g);
            freq_start = str2double(query(g,':sense:freq:start?'));
            freq_stop = str2double(query(g,':sense:freq:stop?'));
            nPoints = str2double(query(g,':sweep:points?'));
            freq = linspace(freq_start,freq_stop,nPoints);
            fclose(g);
        end

        function [Fre] = Get_Fre(obj,span,nPoints)

            g = obj.Init();

            fopen(g);

            fre_length=nPoints/4;
            fre_start=str2double(query(g,'SENSe:SPECtrum:FREQuency:STARt?'));
            fre_end=str2double(query(g,'SENSe:SPECtrum:FREQuency:STOP?'));
            df=span*1e3/fre_length;
            Fre=(fre_start+df:df:fre_end);
            fclose(g);
        end
        function  Auto_Calibration_OFF(obj)
         g = obj.Init();
         fopen(g);
         fprintf(g,'CALIBRATION:AUTO OFF');
         fclose(g);
        end
        function  T=GET_Auto_Information(obj)
         g = obj.Init();
         fopen(g);
         T=str2double(query(g,'CALIBRATION:AUTO?'));
         fclose(g);
        end

        function  L=Auto_Calibration(obj)
         g = obj.Init();
         fopen(g);
         L=str2double(query(g,'*CAL'));
         fclose(g);
        end

    end
end