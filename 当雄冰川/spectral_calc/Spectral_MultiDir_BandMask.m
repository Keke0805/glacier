% �������ļ��У�����Ĥ���вü������Ը�ͼ�񲨶�ֵ(8δ����)����Ԥ����
% ���������Ľ�����浽BandMask�ļ��У�����Ϊ*_mask.tif�ļ�
clc;
clear all;


bandnum = 9;

xlimits = [540236.5063  544936.6699];   %��Ҫ��ȡ�����귶Χ
ylimits = [3855234.1772 3859366.0181];  %Aera1 С

% ��ȡShapefile
shp_filename = 'E:\Ψ���յ��۱���_LS8_2013-2020\shp_data\dangxiong.shp';
shp = shaperead(shp_filename);
shp_info = shapeinfo(shp_filename);

% ��ȡtif_file
foldernum = 0;
folders = dir(fullfile('E:\Ψ���յ��۱���_LS8_2013-2020\data\LC*'));
for i = 1:length(folders)
    if folders(i).isdir
        foldernum = foldernum+1;
    end
end
%������---------------------------------------------------------
h = waitbar(0, 'please wait');
s = 0;
step = foldernum;
%������---------------------------------------------------------

for i = 1:length(folders)
    if ~folders(i).isdir
        continue;
    end

    % ��ȡMTL�ļ�
    dirpath = [folders(i).folder, '\', folders(i).name, '\'];
    str = [dirpath, '*MTL.txt'];
    file = dir(fullfile(str));                  %�ҵ�'MTL.txt'�ļ�
    path = [dirpath, file.name];
    [coef_k,coef_b,strDate,SunElvAng] = readMTL(path);

    % ��ȡB9�ļ���������Ĥ
    str = [dirpath, '*B9.TIF']; %1375 nm
    file = dir(fullfile(str));                  %�ҵ�'B9.TIF'�ļ�
    if isempty(file)                            %L2����Ʒû��B8��B9
        str = [dirpath, '*B6.TIF'];             %û��B9������B6��1610 nm����
        file = dir(fullfile(str));
    end

    path = [dirpath, file.name];
    [A,RA] = readgeoraster(path);
    [B,RB] = mapcrop(A,RA,xlimits,ylimits);
    X = RB.XWorldLimits(1) : RB.SampleSpacingInWorldX : RB.XWorldLimits(2);     % �����X����
    Y = RB.YWorldLimits(2) : -RB.SampleSpacingInWorldX : RB.YWorldLimits(1);    % �����Y����
    [X, Y] = meshgrid(X, Y);
    [lat, lon] = projinv(RB.ProjectedCRS, X, Y);    %��x-y����ӳ�䵽��γ��
%     disp('�ֲü���ɣ�');

    XArray=[shp(:).X];%���ж���εľ���
    YArray=[shp(:).Y];%%���ж���ε�γ��
%     imshow(B);
    mask = inpolygon (lon, lat, XArray, YArray);
    B_size = size(B);
    mask_tif = zeros([B_size(1),B_size(2),bandnum], 'double');

    relf = double(B)*coef_k(9) + coef_b(9);
    relf = relf/cosd(SunElvAng);
    relf(~mask) = nan;
    mask_tif(:,:,9) = relf;

    for j = 1:7
        str = [dirpath, '*B', num2str(j,'%d'),'.TIF'];
        file = dir(fullfile(str));                  %�ҵ�'Bi.TIF'�ļ�
        path = [dirpath, file.name];
        [A,RA] = readgeoraster(path);
%         [A,RA] = geotiffread(path);        %Ҳ�����ô˺�����ȡ�ļ�����ϵͳ���Ƽ�
        info = geotiffinfo(path);

        [B,RB] = mapcrop(A,RA,xlimits,ylimits);     %���ݴ�������ȡͼ��

        relf = double(B)*coef_k(j) + coef_b(j);
        relf = relf/cosd(SunElvAng);
        relf(~mask) = nan;
        mask_tif(:,:,j) = relf;
        
    end

    str = [char(strDate), '_', folders(i).name, '_mask', '.TIF'];
    path = ['..\BandMask\', str];
    
    %���ɽ�ͼ�ļ�
    % geotiffwrite(path, mask_tif, RB, "GeoKeyDirectoryTag", info.GeoTIFFTags.GeoKeyDirectoryTag, "PhotometricInterpretation", 'Palette', 'BitsPerSample',16 ,'SamplesPerPixel',bandnum);
    geotiffwrite(path, mask_tif, RB, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);


    %������
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %������
end




%������---------------------------------------------------------
delete(h);
%������---------------------------------------------------------