function y = supergaussion(x,fs,bandwidth,detuning,order,domain,flagPlot)
%% Check the input and gain basic information
if nargin < 7
    flagPlot = 0;
end
x = x(:);
N = length(x);
ts = 1/fs;
%% Get the frequency response
% frequency of the samples after FFT
freqSample = 1/N/ts*[0:N/2-1 -N/2:-1]';
% calculate parameter
sigmaToPowOf2m = (bandwidth/2)^(2*order)/log(2);
% calculate frequency response of the filter
filterFreqResp = exp(-(freqSample+detuning).^(2*order)/(2*sigmaToPowOf2m));
% plot if possible
if flagPlot
   plotFilterShape(freqSample,filterFreqResp,bandwidth);
end
% Filter the signal
switch lower(domain)
    case 'td' % time domain
        y = fft(ifft(x).*filterFreqResp);
    case 'fd' % frequency domain
        y = x.*circshift(filterFreqResp,N/2);
    otherwise
        error('You should set either TD or FD!');
end
end

function plotFilterShape(freqSample,filterFreqResp,bandwidth)
% nullIndex = find(freqSample>(2*bandwidth) |...
%     freqSample<(-2*bandwidth));
% freqSample(nullIndex) = [];
% filterFreqResp(nullIndex) = [];
freqSample = circshift(ifftshift(-freqSample./1e9),-1);
figure;
plot(freqSample,10*log10(abs(ifftshift(filterFreqResp))),...
    'Linewidth',1.5);
% xlim([-bandwidth/1e9, bandwidth/1e9]);
xlabel('Relative Frequency (GHz)');
ylabel('Magnitude Response (dB)');
grid on;
end