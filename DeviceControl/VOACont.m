% 阶段1: 设置衰减值
% 创建串口对象
s = serial('COM5', 'BaudRate', 9600, 'Timeout', 30, 'Terminator', 'LF');
fopen(s);
command = sprintf('ATT %.2f', -1);%初始化衰减值-1
fprintf(s, command);
pause(1);
% 读取当前衰减值
 fprintf(s, 'ATT?'); 
pause(1); % 等待设备响应

if s.BytesAvailable > 0
    response = fgetl(s);
    currentAttenuation = str2double(response);
    fprintf('初始衰减值: %.2f dB\n', currentAttenuation);
else
    disp('设备无数据返回');
    currentAttenuation = NaN;
end

folder = 'C:\Users\51721\Desktop\OscCont\lockedRanging\VOA_osc\5050\'; % 设置你要保存的文件夹路径"C:\Users\51721\Desktop\OscCont\lockedRanging\VOA_osc\1090"

% 确保文件夹存在
if ~exist(folder, 'dir')
    mkdir(folder);
end
% 循环 20 次，每次增加 2 dB衰减

for n = 1:20
    newAttenuation(n) = currentAttenuation - 2*(n-1);
    command = sprintf('ATT %.2f', newAttenuation(n));
    fprintf(s, command);
    
    pause(1); % 设备需要时间处理
    
    fprintf(s, 'ATT?');
    pause(1);
    
    if s.BytesAvailable > 0
        updatedAttenuation(n) = str2double(fgetl(s));
        fprintf('第 %d 次调整: 当前衰减值 = %.2f dB\n', n, updatedAttenuation(n));
    else
        disp('设备无数据返回');
    end

end
% 关闭串口
fclose(s);
delete(s);
clear s;