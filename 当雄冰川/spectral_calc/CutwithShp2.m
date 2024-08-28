% 根据shp文件，生成掩膜，对tif文件进行裁剪
clc;
clear;

%%  读取数据
% 读取Shapefile
shp_filename = 'E:\唯格勒当雄冰川_LS8_2013-2020\shp_data\dangxiong.shp';
shp = shaperead(shp_filename);
shp_info = shapeinfo(shp_filename);
% 读取tif
path = 'pic.tif';
[A, RA] = readgeoraster(path);
info=geotiffinfo(path);
%% 粗裁剪
xlimits = [540236.5063  544936.6699];   %需要截取的坐标范围
ylimits = [3855234.1772 3859366.0181];  %Aera1 小


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

%% 写回文件
geotiffwrite('cut.tif', B, RB, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);

% 另一种裁剪，根据像素点裁剪
% A = imread(path);
% cut=A(5000:5800,150:700); %根据自己需要裁减
% cut_lat = lat(5000:5800,150:700);
% cut_lon = lon(5000:5800,150:700);
% imshow(cut);
