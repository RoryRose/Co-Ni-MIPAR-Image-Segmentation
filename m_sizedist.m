[file, path] = uigetfile('.tif','MultiSelect','off');
cd(path)
imshow([path,file]);

inf=imfinfo([path,file]);
[realToImageConv,Unit_Real,Unit_Image]=f_getSEMScaleData(file);
[outputdata,croppedImage]=f_segmentImage(path,file,realToImageConv);

%% plot histogram
outputdata(outputdata.Perimeter<1,:)=[];
figure()
h=histogram(outputdata.Equivelant_Area_Diameter);
binCenters=h.BinEdges + h.BinWidth/2;
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

%% Fit to multimodal distribution
numGaussians=2;

[tEstimate,TrialError,NumTrials]=f_FitmultGauss(numGaussians,binCenters,h.BinCounts);
%% stacked histogram
figure()
bar(binCenters,cumsum(h.BinCounts))
xlabel(strcat('Equivelant Area Diameter',{' ('},Unit_Real,')'))
ylabel('Cumilative Area Fraction')
%Sanity check
sum(h.BinCounts)-sum(((outputdata.Equivelant_Area_Diameter(:)).^2./4.*pi)./totalarea)
