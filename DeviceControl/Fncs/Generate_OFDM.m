function Generate_OFDM(Rs,gap)

config.Fs = 64e9;
config.Rs = Rs;
config.nFFT = 1024;
config.Fch = config.Fs./config.nFFT;
config.QAMOrder = 16;
config.GapBandwidth = gap;
config.Fawg = 92e9;

ofdmTx = OFDMTxSSB('nFFT',config.nFFT,...
    'nSym',100,...
    'nModCarrier',config.Rs/config.Fch,...
    'qamOrder',config.QAMOrder,...
    'nGapCarrier',config.GapBandwidth/config.Fch);

sig = ofdmTx.Output();

sig = HardClip(sig,3);

awg = AWG();
awg.samplingRate = config.Fawg;
awg.segmentGranularity = 256;
awg.setSamplingRate = config.Fs;
awg.flagResampling = 1;
awg.flagInsertZeros = 0;
awg.fileHeader = sprintf('SSB-%dQAM-%dGBaud',ofdmTx.qamOrder,...
    awg.setSamplingRate/1e9);
awg.wfSaveFolder = 'Waveform';
chConfig.amplitude = 1*[0.8 0 0 0.80];
chConfig.offset = [0 0 0 0];
chConfig.skew = 0;

awg.iqDelayTime = 0e-12;
seq = awg.Output(sig);

% for M8196
arbConfig.amplitude = 1*[0.8 0 0 0.80];
arbConfig.offset = [0 0 0 -0.0083];
arbConfig.skew = 0;
flagCorrection = 0;

send_to_M8196(seq,92e9,arbConfig,0,flagCorrection,1);
end