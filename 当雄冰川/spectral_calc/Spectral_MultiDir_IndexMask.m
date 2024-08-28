% 将处理后的bandMask图像，进行指数计算，并将处理后的结果保存到IndexMask文件夹，
% 保存为*_indexMask.tif文件
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


for i=1:length(files)
    % 读取每个文件的波段值
    filename = files(i).name;
    path = [files(i).folder,'\', files(i).name];
    [A, RA] = readgeoraster(path);
    info = geotiffinfo(path);

    strDate = extractBefore(filename,"_"); % 提取日期
    strName = extractBetween(filename,"_","_mask"); % 提取文件名

    index49 = A(:,:,4) ./ A(:,:,9);  % 655/1375
    index46 = A(:,:,4) ./ A(:,:,6);  % 655/1610
    VNIR_1375 = (A(:,:,1).*A(:,:,2).*A(:,:,3).*A(:,:,4).*A(:,:,5)) ./ (A(:,:,9).^5);    % VNIR/1375^5
    
    IndexMask = cat(3,index49,index46,VNIR_1375);

    str = [char(strDate), '_', char(strName), '_IndexMask', '.TIF'];
    path = ['..\IndexMask\', str];
    
    %生成IndexMask文件
    geotiffwrite(path, IndexMask, RA, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);

    %进度条
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %进度条
end

%进度条---------------------------------------------------------
delete(h);
%进度条---------------------------------------------------------