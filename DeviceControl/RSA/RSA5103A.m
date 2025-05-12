classdef RSA5103A < Device5103

    properties (Dependent = true)

    end

    methods
        function obj = RSA5103A(addr)
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



        function [pow,nPoints] = Read_Spectrum(obj,channel)
            g = obj.Init();
            g.InputBufferSize = 1e6;
            g.OutputBufferSize = 1e6;
            fopen(g);
            fprintf(g,'INITiate:CONTinuous OFF;INITiate:IMMediate');
            cmd = sprintf('READ:SPECtrum:Trace%d?',channel);
            fprintf(g,cmd);
            % discard first 6 digits
            a = fread(g,7);
            nPoints = str2double(strjoin(cellstr(char(a(3:end))),''));
            % now read the data of 4 bytes in little endian order
            pow = fread(g,nPoints/4,'float');
            fprintf(g,'INITiate:CONTinuous ON;INITiate:IMMediate');
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

    end
end