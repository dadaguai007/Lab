function c = calc_cspr_dca(mu,sigma)
pc = sqrt(mu^2-sigma^2);
ps = mu - pc;
c = pc/ps;