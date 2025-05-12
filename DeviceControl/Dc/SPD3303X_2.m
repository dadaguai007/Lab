classdef SPD3303X_2 < handle
    properties
%         RsrcName
        curr
        volt
        output
    end
    
    methods
        function obj = connect(~)
           %RsrcName = sprintf('USB0::0x1AB1::0x0E11::DP8C232502762::0::INSTR');
           obj = instrfind('RsrcName','USB0::0xF4EC::0x1430::SPD3XIDQ5R4698::0::INSTR');
           if isempty(obj)
               obj = visa('agilent', 'USB0::0xF4EC::0x1430::SPD3XIDQ5R4698::0::INSTR');
           else
               fclose(obj);
               obj = obj(1);
           end
        end
        

        
%         function apply_voltcurr(obj,ch,volt,curr)
%             g = obj.connect;
%             fopen(g);
%             cmd = sprintf(':APPL CH%d,%1.3f,%1.3f',ch,volt,curr);
%             fprintf(g,cmd);
%             fclose(g);
%         end
%         
%         function val = get_voltage(obj,ch)
%             g = obj.connect;
%             fopen(g);
%             cmd = sprintf(':SOUR%d:VOLT?',ch);
%             txt = query(g,cmd);
%             %             val = str2double(txt);
%             disp(txt);
%             fclose(g);
%         end
        
        function apply_volt(obj,channel,volt)
            g = obj.connect;
            fopen(g);
            cmd = sprintf('CH%d:VOLTage %1.2f',channel,volt);
            fprintf(g,cmd);
%             current_volt=fscanf(DSG800,':MEAS:VOLT? CH1');
%             disp(current_volt);
            fclose(g);
        end   
        
        function apply_curr(obj,channel,curr)
            g = obj.connect;
            fopen(g);
             cmd = sprintf('CH%d:curr %1.2f',channel,curr);
            fprintf(g,cmd);
            fclose(g);
        end

        function volt = read_volt(obj,channel)
            g = obj.connect;
            fopen(g);
            cmd = sprintf('CH%d:VOLTage?',channel);
            txt = query(g,cmd);
            volt = str2double(txt);
            fclose(g);
        end
    end
end