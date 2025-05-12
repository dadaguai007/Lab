function autoplot(x,y)
% color = 'kbrgmcy';
color = {[7 47 65]/255,[65 161 161]/255, [21 171 38]/255,...
    [242 177 52]/255, [89 120 237]/255, [237 85 59]/255, [170 79 237]/255};
marker = 'sodvp^hx';
marker_size = 6;
for idx = 1:size(y,2)
    idx_iter = mod(idx,length(color));
    plot(x,y(:,idx),'Color',color{idx_iter},'Linewidth',1.2,...
        'Marker',marker(idx_iter),'MarkerEdgeColor',color{idx_iter},...
        'MarkerSize',marker_size);
    hold on;
end
set(gcf,'pos',[400,400,400,360]);
set(gca,'Linewidth',1.5);
grid on;
box on;
