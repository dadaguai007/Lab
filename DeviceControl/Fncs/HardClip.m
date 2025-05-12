function [y, papri, paprq] = HardClip(x, cr, cl)

if nargin<3
    delta = sqrt(mean(x.*conj(x)));
    clippingLevel = delta*cr;
elseif nargin <4
    clippingLevel = cl;
end


if isreal(x)
    y = min(max(x,-1*clippingLevel),clippingLevel);
else
    amp = abs(x);
    phi = angle(x);
    amp2 = min(clippingLevel,amp);
    y = amp2 .* exp(1i*phi);
    papri = calc_papr(real(y));
    paprq = calc_papr(imag(y));
    fprintf('PAPRx = %f,PAPRy= %f\n',papri,paprq);
end