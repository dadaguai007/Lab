function data2 = applyPreComp(data,fs,fstop,f_pre,rsp_pre)
% data: input data
% fs: sampling rate
% f_pre: frequency of pre-compensation vector
% rsp_pre: response of pre-compensation vector
% 对AWG的输出信号做预补偿
% if we don't have negative frequencies, mirror them
if (min(f_pre) >= 0)
    if (f_pre(1) == 0)            % don't duplicate zero-frequency
        startIdx = 2;
    else
        startIdx = 1;
    end
%     rsp_pre = rsp_pre./abs(rsp_pre(startIdx));
    f_pre = [-1 * flipud(f_pre); f_pre(startIdx:end)];
    rsp_pre = [conj(flipud(rsp_pre)); rsp_pre(startIdx:end)]; % negative side must use complex conjugate
end
fdata = fftshift(fft(data));
points = length(fdata);
newFreq = linspace(-0.5, 0.5-1/points, points) * fs;
% interpolate the correction curve to match the data
corrLin = interp1(f_pre, rsp_pre, newFreq, 'pchip', 1);
corrLin(abs(newFreq)>=fstop) = 1;
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