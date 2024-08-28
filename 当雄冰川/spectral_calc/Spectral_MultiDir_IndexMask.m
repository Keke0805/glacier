% ��������bandMaskͼ�񣬽���ָ�����㣬���������Ľ�����浽IndexMask�ļ��У�
% ����Ϊ*_indexMask.tif�ļ�
clc;
clear;


dirpath = 'E:\Ψ���յ��۱���_LS8_2013-2020\BandMask\';
str = [dirpath, '*.tif'];
files = dir(str);   % ��ȡ����tif�ļ���Ϣ


%������---------------------------------------------------------
h = waitbar(0, 'please wait');
s = 0;
step = length(files);
%������---------------------------------------------------------


for i=1:length(files)
    % ��ȡÿ���ļ��Ĳ���ֵ
    filename = files(i).name;
    path = [files(i).folder,'\', files(i).name];
    [A, RA] = readgeoraster(path);
    info = geotiffinfo(path);

    strDate = extractBefore(filename,"_"); % ��ȡ����
    strName = extractBetween(filename,"_","_mask"); % ��ȡ�ļ���

    index49 = A(:,:,4) ./ A(:,:,9);  % 655/1375
    index46 = A(:,:,4) ./ A(:,:,6);  % 655/1610
    VNIR_1375 = (A(:,:,1).*A(:,:,2).*A(:,:,3).*A(:,:,4).*A(:,:,5)) ./ (A(:,:,9).^5);    % VNIR/1375^5
    
    IndexMask = cat(3,index49,index46,VNIR_1375);

    str = [char(strDate), '_', char(strName), '_IndexMask', '.TIF'];
    path = ['..\IndexMask\', str];
    
    %����IndexMask�ļ�
    geotiffwrite(path, IndexMask, RA, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);

    %������
    s=s+1;
    str = ['computing...', num2str(int8(s/step*100),'%3d'),'%'];
    waitbar(s/step,h,str);
    %������
end

%������---------------------------------------------------------
delete(h);
%������---------------------------------------------------------