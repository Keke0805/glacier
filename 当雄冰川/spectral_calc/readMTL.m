function [coef_k,coef_b,strDate,SunElvAng] = readMTL(path)
%UNTITLED Summary of this function goes here
%  读取MTL文件
% 输入：MLT文件路径
% 输出：coef_k,coef_b,strDate,SunElvAng
fileID = fopen(path);
lines = textscan(fileID, '%s', 'Delimiter', '\n');
allLines = lines{1};

bandnum = 9;
coef_k = zeros([bandnum,1], 'double');      %像素值转换为反射率的系数
coef_b = zeros([bandnum,1], 'double');
for j =1:length(allLines)
    line = allLines(j);
    str = strfind(line,'DATE_ACQUIRED');
    if ~isempty(str{1,1})
        strDate = extractAfter(line,'= ');
    end
    str = strfind(line,'SUN_ELEVATION');
    if ~isempty(str{1,1})
        strSE = extractAfter(line,'=');
        SunElvAng = str2double(strSE);
    end
    for k =1:bandnum
        tag = ['REFLECTANCE_MULT_BAND_',num2str(k)];
        str = strfind(line, tag);
        if ~isempty(str{1,1})
            strK = extractAfter(line,'=');
            coef_k(k) = str2double(strK);
        end
        tag = ['REFLECTANCE_ADD_BAND_',num2str(k)];
        str = strfind(line, tag);
        if ~isempty(str{1,1})
            strB = extractAfter(line,'=');
            coef_b(k) = str2double(strB);
        end
    end
end
end