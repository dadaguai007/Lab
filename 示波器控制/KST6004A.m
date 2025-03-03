classdef KST6004A < Device

    properties

    end

    methods
        function obj = KST6004A(USBaddr)
            if nargin <1
                obj.USBaddr = '0x0957::0x1790::MY58031665';
            else
                obj.USBaddr = USBaddr;
            end
            obj.DeviceName = 'KEYSIGHT MSOX6004A oscilloscope';
            obj.VISA_Vendor = 'agilent';
            obj.ConnectionType = 'USB';
        end

        function y = readwaveform(obj,chIDs)
            if nargin < 2
                chIDs = 1;
            end
            g = obj.Init();
            %%
            set(g, 'Timeout', 5);
            set(g, 'InputBufferSize', 1e7);    %when ASCii type
            %
            fopen(g);
            % data acqusition
            % setting
            fprintf(g,':STOP');
            fprintf(g, ':ACQ:INT OFF'); % interpolation off
            fprintf(g,':ACQ:MODE RTIME');  %real time mode
            fprintf(g,':ACQ:AVER OFF'); % average mode off
            fprintf(g,':WAVeform:POINts MAX');
            fprintf(g,':WAVeform:UNSigned ON'); % make sure the data is in unsigned mode

            % collect information
            nPoints = str2double(query(g, ':WAVeform:POINts?')); % change the record length record length
            SampRate = str2double(query(g, ':ACQ:SRATE?')); % recover the sampling rate

            % enable the status resister
            fprintf(g, '*CLS');% Clear event que
            fprintf(g, '*ESE 1');
            fprintf(g, '*SRE 0');

            for iCh = 1:length(chIDs)
                chID = chIDs(iCh);
                % set the waveform capture
                fprintf(g, ':waveform:source channel%d', chID);  % choose channel
                fprintf(g, ':waveform:format word'); % binary transfer mode.
                fprintf(g, ':waveform:BYTeorder LSBFirst'); % byte order LSB

                % read waveform
                fprintf(g, ':waveform:DATA?'); %
                % waiting_in_sec(0.1);
                pause(0.1);
                % use binblockread to read the waveform data
                Aall = binblockread(g,'uint16');

                % Get the preamble block  split the preambleBlock into individual pieces of info
                preambleBlock = query(g,':WAVEFORM:PREAMBLE?');
                preambleBlock = regexp(preambleBlock,',','split');

                % store all this information into a waveform structure for later use
                info.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
                info.Type = str2double(preambleBlock{2});
                info.Points = str2double(preambleBlock{3});
                info.Count = str2double(preambleBlock{4});      % This is always 1
                info.XIncrement = str2double(preambleBlock{5}); % in seconds
                info.XOrigin = str2double(preambleBlock{6});    % in seconds
                info.XReference = str2double(preambleBlock{7});
                info.YIncrement = str2double(preambleBlock{8}); % V
                info.YOrigin = str2double(preambleBlock{9});
                info.YReference = str2double(preambleBlock{10});
                info.RawData = Aall;

                y(:,iCh) = (Aall - info.YReference) * info.YIncrement + info.YOrigin;
            end

            % Run again
            fprintf(g,':RUN');

            fprintf(g, '*CLS');
            fclose(g);
        end
    end
end
