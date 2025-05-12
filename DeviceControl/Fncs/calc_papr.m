function papr_db = calc_papr(in)
papr_db = max(in.*conj(in))./mean(in.*conj(in));