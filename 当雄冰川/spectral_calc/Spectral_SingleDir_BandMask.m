% 对单个文件夹，用掩膜进行裁剪，并对各图像波段值(8未处理)进行处理，
% 并将处理后的结果保存到*_mask.tif文件中

clc;
close all;
clear all;

dirpath = 'E:\唯格勒当雄冰川_LS8_2013-2020\data\LC81330362013362LGN01\';
bandnum = 9;

xlimits = [540236.5063  544936.6699];   %需要截取的坐标范围
ylimits = [3855234.1772 3859366.0181];  %Aera1 小


%进度条：
h = waitbar(0, 'please wait');
s = 0;
step = 2*bandnum + 1;
%进度条

spec = zeros([3,bandnum], 'double');
spec(1,:) = [1 2 3 4 5 6 7 8 9];
spec(2,:) = [443 483 563 655 865 1610 2220 590 1375];

str = [dirpath, '*MTL.txt'];
file = dir(fullfile(str));                  %找到'MTL.txt'文件
path = [dirpath, file.name];
[coef_k,coef_b,strDate,SunElvAng] = readMTL(path);


%进度条
s=s+1;
str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
waitbar(s/step,h,str);
%进度条

%files = dir(fullfile('..\LC81330362013362LGN01\*B1.TIF'));
% 读取Shapefile
shp_filename = 'E:\唯格勒当雄冰川_LS8_2013-2020\shp_data\dangxiong.shp';
shp = shaperead(shp_filename);
shp_info = shapeinfo(shp_filename);

str = [dirpath, '*B1.TIF'];
file = dir(fullfile(str));                  %找到'B1.TIF'文件
path = [dirpath, file.name];
[A,RA] = readgeoraster(path);
[B,RB] = mapcrop(A,RA,xlimits,ylimits);
X = RB.XWorldLimits(1) : RB.SampleSpacingInWorldX : RB.XWorldLimits(2);     % 计算出X坐标
Y = RB.YWorldLimits(2) : -RB.SampleSpacingInWorldX : RB.YWorldLimits(1);    % 计算出Y坐标
[X, Y] = meshgrid(X, Y);
[lat, lon] = projinv(RB.ProjectedCRS, X, Y);    %把x-y坐标映射到经纬度
disp('粗裁剪完成！');

XArray=[shp(:).X];%所有多边形的经度
YArray=[shp(:).Y];%%所有多边形的纬度
% [shp_lat, shp_lon] = projinv(p, XArray, YArray);

%% 生成掩膜，裁剪
imshow(B);
mask = inpolygon (lon, lat, XArray, YArray);
B(~mask) = nan;
imshow(B);
B_size = size(B);
mask_tif = zeros([B_size(1),B_size(2),bandnum], 'double');

for i = 1:bandnum
    if i==8
        continue;
    end
    str = [dirpath, '*B', num2str(i,'%d'),'.TIF'];
    file = dir(fullfile(str));                  %找到'Bi.TIF'文件
    path = [dirpath, file.name];
    [A,RA] = readgeoraster(path);
    %[A,RA] = geotiffread(path);        %也可以用此函数读取文件，但系统不推荐
    info = geotiffinfo(path);

    [B,RB] = mapcrop(A,RA,xlimits,ylimits);     %根据大地坐标截取图像
    B(~mask) = nan;

    relf = double(B)*coef_k(i) + coef_b(i);
    relf = relf/cosd(SunElvAng);
    mask_tif(:,:,i) = relf;
    %进度条
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %进度条

    
    %进度条
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %进度条

end
str = 'LC81330362013362LGN01_mask.TIF';
path = ['..\BandMask\', str];

%生成截图文件
% geotiffwrite(path, mask_tif, RB, "GeoKeyDirectoryTag", info.GeoTIFFTags.GeoKeyDirectoryTag, "PhotometricInterpretation", 'Palette', 'BitsPerSample',16 ,'SamplesPerPixel',bandnum);
geotiffwrite(path, mask_tif, RB, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);


%进度条
delete(h);
%进度条