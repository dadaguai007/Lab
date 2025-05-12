function [data] = callAWGpreCompensation(data,fs,freq,cplxCorr)
% reverse the channel response
cplxCorr = 1 ./ cplxCorr;
% if we don't have negative frequencies, mirror them
if (min(freq) >= 0)
    if (freq(1) == 0)            % don't duplicate zero-frequency
        startIdx = 2;
    else
        startIdx = 1;
    end
    freq = [-1 * flipud(freq); freq(startIdx:end)];
    cplxCorr = [conj(flipud(cplxCorr)); cplxCorr(startIdx:end)]; % negative side must use complex conjugate
end
fdata = fftshift(fft(data));
points = length(fdata);
newFreq = linspace(-0.5, 0.5-1/points, points) * fs;
% interpolate the correction curve to match the data
corrLin = interp1(freq, cplxCorr, newFreq, 'pchip', 1);
% apply the correction and convert back to time domain
% (it seems that corrLin is sometimes a row, sometimes a column...)
try
    data2 = ifft(fftshift(fdata .* corrLin));
catch
    try
        data2 = ifft(fftshift(fdata .* (corrLin.')));
    catch
        errordlg('error in FFT');
    end
end
data2 = real(data2);
scale = max(abs(data2));
% if (scale > 1)
%     data2(data2 > 1) = 1;
%     data2(data2 < -1) = -1;
% %     msgbox('DAC values on channel %d were clipped due to freq/phase response correction. Please reduce DAC range to %d%% to avoid clipping');
% end
data = data2;

end