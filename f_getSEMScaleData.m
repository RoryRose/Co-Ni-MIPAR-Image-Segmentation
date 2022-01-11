function [IPS_Value,IPSUnit_Num,IPSUnit_Den]=f_getSEMScaleData(filename)
Matrix = readtable(filename,'FileType','text','ReadVariableNames',false);
ImageTable = table2cell(Matrix);
clear Matrix
info=imfinfo(filename);
% Tries to search for Image Pixel Size tag stored in Zeiss tif image
% files.
row_IPS = strcmp(ImageTable(:,1),'Image Pixel Size');
if sum(row_IPS) % If that tag can be found it does the following.
    IPS = sprintf('%s/pixel',string(ImageTable(row_IPS==1,2)));
    IPS_Value = extractBefore(IPS,' ');
    IPS_Value =  str2double(IPS_Value);
    IPS_Unit = extractAfter(IPS,' ');
    IPSUnit_Num = extractBefore(IPS_Unit,'/');
    IPSUnit_Den = extractAfter(IPS_Unit,'/');
elseif isfield(info,'XResolution') % If the tag CANNOT be found it does the following.
    IPS_Value = (info.XResolution/10^4)^-1;
    IPSUnit_Num = 'um';
    IPSUnit_Den = 'pixel';
else
    pop = warndlg('Code cannot interpret metadata');
end

% This is used to confirm to the user what the image's scale is
%message = sprintf('Scale for ImageJ = %s %s/%s\nOR %s %s/%s\n',...
%    string(1/IPS_Value),IPSUnit_Den,IPSUnit_Num,string(IPS_Value),IPSUnit_Num,IPSUnit_Den);
%disp(message);

%f = msgbox(message,'Output','help');