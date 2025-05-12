function [fSamp, powSpecRes] = OSA(optSig, fs, res, flagPlot)
% this function is used to emulate the optical spectrum analyzer with
% certain resoluation bandwidth at the unit of Hz.
% originally written by Dr. Ming Li, re-written by Tianwai@PSRL.KAIST
if nargin < 4
    flagPlot = 0;
end
% number of samples
N = length(optSig);
ts = 1/fs;
% frequency correspond to the samples in frequency domain
f = [0:N/2-1 -N/2:-1].' / N / ts;
% calculate the Fourier transform of the complex envelope, note:
% 1. Use ifft for consistency with Agrawal's "nonlinear fiber optics"
% 2. Appropriate coefficient after ifft
compEnvf = fft(optSig) * ts; % modified by Tianwai to reverse the spectrum, 1) change ifft to fft; 2) remove *N
% Then calculate the power spectrum (W/Hz)
powSpec = (real(compEnvf).^2 + imag(compEnvf).^2) / (N * ts);
% cyclic shift the frequency vector and the power spectrum
f = circshift(f, N/2);
powSpec = circshift(powSpec, N/2);
% generate spline interpolation of the power spectrum
ppPowSpec = spline(f, powSpec);
% and its indefinite integration
ppPowSpecInt = fnint(ppPowSpec);
% generate sampling frequency points of the OSA
fSamp = f;
fSamp(fSamp<(min(f)+res/2)) = [];
fSamp(fSamp>(max(f)-res/2)) = [];
% then the starting points of the definite integral
fl = fSamp - res/2;
% and the end points of the definite integrals
fr = fSamp + res/2;
% power spectrum with specified resolution
powSpecRes = ppval(ppPowSpecInt, fr) - ppval(ppPowSpecInt, fl);
if flagPlot
    % Finally plot the power spectrum
    plot(fSamp/1e9, 10*log10(powSpecRes/1e-3));
    xlabel('Detuning frequency (GHz)');
    ylabel(sprintf('Power spectrum at %g resolution (dBm)', res));
end
end