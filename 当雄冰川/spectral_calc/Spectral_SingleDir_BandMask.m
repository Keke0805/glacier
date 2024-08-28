% �Ե����ļ��У�����Ĥ���вü������Ը�ͼ�񲨶�ֵ(8δ����)���д���
% ���������Ľ�����浽*_mask.tif�ļ���

clc;
close all;
clear all;

dirpath = 'E:\Ψ���յ��۱���_LS8_2013-2020\data\LC81330362013362LGN01\';
bandnum = 9;

xlimits = [540236.5063  544936.6699];   %��Ҫ��ȡ�����귶Χ
ylimits = [3855234.1772 3859366.0181];  %Aera1 С


%��������
h = waitbar(0, 'please wait');
s = 0;
step = 2*bandnum + 1;
%������

spec = zeros([3,bandnum], 'double');
spec(1,:) = [1 2 3 4 5 6 7 8 9];
spec(2,:) = [443 483 563 655 865 1610 2220 590 1375];

str = [dirpath, '*MTL.txt'];
file = dir(fullfile(str));                  %�ҵ�'MTL.txt'�ļ�
path = [dirpath, file.name];
[coef_k,coef_b,strDate,SunElvAng] = readMTL(path);


%������
s=s+1;
str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
waitbar(s/step,h,str);
%������

%files = dir(fullfile('..\LC81330362013362LGN01\*B1.TIF'));
% ��ȡShapefile
shp_filename = 'E:\Ψ���յ��۱���_LS8_2013-2020\shp_data\dangxiong.shp';
shp = shaperead(shp_filename);
shp_info = shapeinfo(shp_filename);

str = [dirpath, '*B1.TIF'];
file = dir(fullfile(str));                  %�ҵ�'B1.TIF'�ļ�
path = [dirpath, file.name];
[A,RA] = readgeoraster(path);
[B,RB] = mapcrop(A,RA,xlimits,ylimits);
X = RB.XWorldLimits(1) : RB.SampleSpacingInWorldX : RB.XWorldLimits(2);     % �����X����
Y = RB.YWorldLimits(2) : -RB.SampleSpacingInWorldX : RB.YWorldLimits(1);    % �����Y����
[X, Y] = meshgrid(X, Y);
[lat, lon] = projinv(RB.ProjectedCRS, X, Y);    %��x-y����ӳ�䵽��γ��
disp('�ֲü���ɣ�');

XArray=[shp(:).X];%���ж���εľ���
YArray=[shp(:).Y];%%���ж���ε�γ��
% [shp_lat, shp_lon] = projinv(p, XArray, YArray);

%% ������Ĥ���ü�
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
    file = dir(fullfile(str));                  %�ҵ�'Bi.TIF'�ļ�
    path = [dirpath, file.name];
    [A,RA] = readgeoraster(path);
    %[A,RA] = geotiffread(path);        %Ҳ�����ô˺�����ȡ�ļ�����ϵͳ���Ƽ�
    info = geotiffinfo(path);

    [B,RB] = mapcrop(A,RA,xlimits,ylimits);     %���ݴ�������ȡͼ��
    B(~mask) = nan;

    relf = double(B)*coef_k(i) + coef_b(i);
    relf = relf/cosd(SunElvAng);
    mask_tif(:,:,i) = relf;
    %������
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %������

    
    %������
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %������

end
str = 'LC81330362013362LGN01_mask.TIF';
path = ['..\BandMask\', str];

%���ɽ�ͼ�ļ�
% geotiffwrite(path, mask_tif, RB, "GeoKeyDirectoryTag", info.GeoTIFFTags.GeoKeyDirectoryTag, "PhotometricInterpretation", 'Palette', 'BitsPerSample',16 ,'SamplesPerPixel',bandnum);
geotiffwrite(path, mask_tif, RB, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);


%������
delete(h);
%������