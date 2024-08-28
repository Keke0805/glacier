% 根据处理后的波段tif文件，计算波段值的均值、最大值、最小值，并保存到xlsx文件

clc;
clear;

dirpath = 'E:\唯格勒当雄冰川_LS8_2013-2020\BandMask\';
str = [dirpath, '*.tif'];
files = dir(str);   % 获取所有tif文件信息


%进度条---------------------------------------------------------
h = waitbar(0, 'please wait');
s = 0;
step = length(files);
%进度条---------------------------------------------------------

% 两个思路：
% 先读取各波段值，保存在图像中
% 第一个：波段值的均值 最大值 最小值 再计算指数值
% 第二个：指数值的均值 最大值 最小值 前10%、前20%的均值

row = 0;    %str_spec的行计数
bandnum = 9;

sz = [length(files) bandnum+1];
varNames = {'data', '443', '483', '563', '655', '865', '1610', '2220', '590', '1375'};
varTypes = {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
Table = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


for i=1:length(files)
    row = row + 1;

    % 读取每个文件的波段值
    filename = files(i).name;
    path = [files(i).folder,'\', files(i).name];
    [A, RA] = readgeoraster(path);

    strdate = extractBefore(filename,"_"); %提取日期

    Table.data(row) = strdate;
    for j = 1:bandnum 
        bandj = A(:,:,j);
        relf_band = reshape(bandj, size(bandj,1)*size(bandj,2),1);
        relf_band = relf_band(~isnan(relf_band));   %去除nan值
%         relf_band = mean(relf_band);
        relf_band = max(relf_band);
%         relf_band = min(relf_band);
        
        Table{row,j+1} = relf_band;
        
    end
    %进度条
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %进度条
end

writetable(Table,'maxBand.xlsx');

%进度条---------------------------------------------------------
delete(h);
%进度条---------------------------------------------------------

