function str_array = generate_legend(prefix,postfix,data)
% this function generate string for legend use
for idx = 1:length(data)
    str_array{idx}=sprintf('%s %s %s',prefix,num2str(data(idx)),postfix);
end