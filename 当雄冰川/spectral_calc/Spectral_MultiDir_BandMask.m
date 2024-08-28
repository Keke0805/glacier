% 对所有文件夹，用掩膜进行裁剪，并对各图像波段值(8未处理)进行预处理，
% 并将处理后的结果保存到BandMask文件夹，保存为*_mask.tif文件
clc;
clear all;


bandnum = 9;

xlimits = [540236.5063  544936.6699];   %需要截取的坐标范围
ylimits = [3855234.1772 3859366.0181];  %Aera1 小

% 读取Shapefile
shp_filename = 'E:\唯格勒当雄冰川_LS8_2013-2020\shp_data\dangxiong.shp';
shp = shaperead(shp_filename);
shp_info = shapeinfo(shp_filename);

% 读取tif_file
foldernum = 0;
folders = dir(fullfile('E:\唯格勒当雄冰川_LS8_2013-2020\data\LC*'));
for i = 1:length(folders)
    if folders(i).isdir
        foldernum = foldernum+1;
    end
end
%进度条---------------------------------------------------------
h = waitbar(0, 'please wait');
s = 0;
step = foldernum;
%进度条---------------------------------------------------------

for i = 1:length(folders)
    if ~folders(i).isdir
        continue;
    end

    % 读取MTL文件
    dirpath = [folders(i).folder, '\', folders(i).name, '\'];
    str = [dirpath, '*MTL.txt'];
    file = dir(fullfile(str));                  %找到'MTL.txt'文件
    path = [dirpath, file.name];
    [coef_k,coef_b,strDate,SunElvAng] = readMTL(path);

    % 读取B9文件并生成掩膜
    str = [dirpath, '*B9.TIF']; %1375 nm
    file = dir(fullfile(str));                  %找到'B9.TIF'文件
    if isempty(file)                            %L2级产品没有B8和B9
        str = [dirpath, '*B6.TIF'];             %没有B9波段用B6：1610 nm代替
        file = dir(fullfile(str));
    end

    path = [dirpath, file.name];
    [A,RA] = readgeoraster(path);
    [B,RB] = mapcrop(A,RA,xlimits,ylimits);
    X = RB.XWorldLimits(1) : RB.SampleSpacingInWorldX : RB.XWorldLimits(2);     % 计算出X坐标
    Y = RB.YWorldLimits(2) : -RB.SampleSpacingInWorldX : RB.YWorldLimits(1);    % 计算出Y坐标
    [X, Y] = meshgrid(X, Y);
    [lat, lon] = projinv(RB.ProjectedCRS, X, Y);    %把x-y坐标映射到经纬度
%     disp('粗裁剪完成！');

    XArray=[shp(:).X];%所有多边形的经度
    YArray=[shp(:).Y];%%所有多边形的纬度
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
        file = dir(fullfile(str));                  %找到'Bi.TIF'文件
        path = [dirpath, file.name];
        [A,RA] = readgeoraster(path);
%         [A,RA] = geotiffread(path);        %也可以用此函数读取文件，但系统不推荐
        info = geotiffinfo(path);

        [B,RB] = mapcrop(A,RA,xlimits,ylimits);     %根据大地坐标截取图像

        relf = double(B)*coef_k(j) + coef_b(j);
        relf = relf/cosd(SunElvAng);
        relf(~mask) = nan;
        mask_tif(:,:,j) = relf;
        
    end

    str = [char(strDate), '_', folders(i).name, '_mask', '.TIF'];
    path = ['..\BandMask\', str];
    
    %生成截图文件
    % geotiffwrite(path, mask_tif, RB, "GeoKeyDirectoryTag", info.GeoTIFFTags.GeoKeyDirectoryTag, "PhotometricInterpretation", 'Palette', 'BitsPerSample',16 ,'SamplesPerPixel',bandnum);
    geotiffwrite(path, mask_tif, RB, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);


    %进度条
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %进度条
end




%进度条---------------------------------------------------------
delete(h);
%进度条---------------------------------------------------------