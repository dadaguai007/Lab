classdef DG535 < Device
    
    properties
        
    end
    
    methods
        function obj = DG535(GPIB_addr)
            if nargin <1
                obj.GPIB_Addr = 16;
            else
                obj.GPIB_Addr = GPIB_addr;
            end
            obj.DeviceName = 'DG535';
            obj.VISA_Vendor = 'agilent';
        end
        
        function Set_Delay(obj,core_num,loop_num)
            B = [4.426E-4 2.28226E-4 2.146E-4];
            Tr = [173.5 168.5 179.5];
            %                 if nargin<1
            %                     channel = 1;
            %                 end
            obj.DevObj = obj.Init();
            fopen(obj.DevObj);
% %             fprintf(obj.DevObj,'*cls');
% %             query(obj.DevObj,'*opc?');
%             cmd=sprintf('TM 0; TR 0,%c',Tr(core_num));
%             fprintf(obj.DevObj,cmd);
            cmd=sprintf('DT 3,2,%c',B(core_num));
            fprintf(obj.DevObj,cmd);
            delay_c = B(core_num)*loop_num+15e-6;
            cmd=sprintf('DT 5,2,%c',delay_c);
            fprintf(obj.DevObj,cmd);
            delay_d = B(core_num)*(loop_num+1)-15e-6;
            cmd=sprintf('DT 6,2,%c',delay_d);
            fprintf(obj.DevObj,cmd);
            fclose(obj.DevObj);
        end
    end
end