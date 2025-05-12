function result = send_to_M8196(data,fs,arbConfig,skew,flagCor,run)
marker1 = [];
marker2 = [];
segmNum = 1; % default: 1
channelMapping = [1 0;0 0;0 0;0 1]; % channel mapping: 1|2 : I|Q

if isempty(arbConfig)
    arbConfig.skew = skew;
    arbConfig.M8196Acorrection = flagCor;
%     arbConfig.amplitude = 1*[0.512 0 0 0.5]; %cspr  =10;T
     arbConfig.amplitude = 1*[0.537 0 0 0.5];
    arbConfig.offset = [0 0 0 -0.0083];
end

result = iqdownload_M8196A_tw(arbConfig, fs, data, marker1, marker2, segmNum, channelMapping, run);