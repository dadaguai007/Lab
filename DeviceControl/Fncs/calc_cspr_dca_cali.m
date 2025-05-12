function c = calc_cspr_dca_cali(mu,sigma,sigma_cali)
pc = sqrt(mu^2-sigma^2+sigma_cali^2);
ps = mu - pc;
c = pc/ps;