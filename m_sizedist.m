%% Select an image
use_multiple_images=true;


if use_multiple_images==true
    [file, path] = uigetfile('.tif','MultiSelect','on');
    imshow([path,file{1}]);
    inf=imfinfo([path,file{1}]);
else
    [file, path] = uigetfile('.tif','MultiSelect','off');
    imshow([path,file]);
    inf=imfinfo([path,file]);
end
cd(path)
%% segment the image
if use_multiple_images==true
    T=table;
    for i=1:length(file)
        [realToImageConv,Unit_Real,Unit_Image]=f_getSEMScaleData(file{i});
        [outputdata,croppedImage]=f_segmentImage(path,file{i},realToImageConv);
        T=[T;outputdata];
    end
    outputdata=T;
else
    [realToImageConv,Unit_Real,Unit_Image]=f_getSEMScaleData(file);
    [outputdata,croppedImage]=f_segmentImage(path,file,realToImageConv);
end

%% plot histogram
%INPUT ===========================================================
% Select the number of gaussians you want to fit to your data
numGaussians=1;
%===========================================================

outputdata(outputdata.Perimeter<1,:)=[];
figure()
h=histogram(outputdata.Equivelant_Area_Diameter);
binCenters=h.BinEdges + h.BinWidth/2;
binCounts=h.BinCounts;
binCenters(end)=[];
%totalarea=inf.Height*inf.Width.*realToImageConv^2;
totalarea=size(croppedImage,1).*size(croppedImage,2).*(realToImageConv.^2);
%ctoA=((binCenters).^2.*4.*pi)./totalarea;%Area fraction of each bin center count 
%CHANGE THIS TO REFECT REALITY BETTER - DO EACH BLOB INDIVIDUALLY!
areafrac=NaN(length(h.BinEdges)-1,1);
for i=1:length(h.BinEdges)-1
    range=[h.BinEdges(i),h.BinEdges(i+1)];
    idx=find((outputdata.Equivelant_Area_Diameter>=range(1))...
        &(outputdata.Equivelant_Area_Diameter<=range(2)));

    areafrac(i)=sum(((outputdata.Equivelant_Area_Diameter(idx)).^2./4.*pi)./totalarea);
end
%h.BinCounts=h.BinCounts.*ctoA;%normalise bin counts by area fraction
h.BinCounts=areafrac';
xlabel(strcat('Equivelant Area Diameter',{' ('},Unit_Real,')'))
ylabel('Area Fraction')



[tEstimate,TrialError,NumTrials]=f_FitmultGauss(numGaussians,binCenters,h.BinCounts);
%% stacked histogram
figure()
bar(binCenters,cumsum(binCounts))
xlabel(strcat('Equivelant Area Diameter',{' ('},Unit_Real,')'))
ylabel('Cumilative Area Fraction')
%Sanity check (should be zero)
total_error=sum(BinCounts)-sum(((outputdata.Equivelant_Area_Diameter(:)).^2./4.*pi)./totalarea)
