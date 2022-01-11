function [outputdata,originalImage,binaryImage]=f_segmentImage(path,baseFileName,realToImageConv)
%BASED ON DEMO BY IMAGE ANALYST 
% https://uk.mathworks.com/matlabcentral/fileexchange/25157-image-segmentation-tutorial?s_tid=srchtitle
%ACCESSED 14/10/21
%Adapted by RR 21

fullFileName=[path,baseFileName];
%baseFileName = 'coins.png';%FOR TESTING ONLY
%folder = fileparts(which(baseFileName)); % Determine where demo folder is (works with all versions).
%fullFileName = fullfile(folder, baseFileName);

imtool close all;  % Close all imtool figures.
format long g;
format compact;
captionFontSize = 14;

originalImage = imread(fullFileName);

message = sprintf('Do you want to Crop the image?');
reply = questdlg(message, 'Crop?', 'Yes', 'No', 'No');
% Note: reply will = '' for Upper right X, 'Yes' for Yes, and 'No' for No.
if strcmpi(reply, 'Yes')
    originalImage=imcrop(originalImage);
end
% Check to make sure that it is grayscale
[~, ~, numberOfColorChannels] = size(originalImage);
if numberOfColorChannels > 1
	promptMessage = sprintf('Your image file has %d color channels. convert it to grayscale?', numberOfColorChannels);
	button = questdlg(promptMessage, 'Continue', 'Convert and Continue', 'Cancel', 'Convert and Continue');
	if strcmp(button, 'Cancel')
		fprintf(1, 'Finished running BlobsDemo.m.\n');
		return;
	end
	% Do the conversion using standard book formula
	originalImage = rgb2gray(originalImage);
end

% Display the grayscale image.
figure(100)
subplot(3, 3, 1);
imshow(originalImage);
% Maximize the figure window.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Force it to display RIGHT NOW (otherwise it might not display until it's all done, unless you've stopped at a breakpoint.)
drawnow;
caption = sprintf('Original image');
title(caption, 'FontSize', captionFontSize);
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.

% Just for fun, let's get its histogram and display it.
[pixelCount, grayLevels] = imhist(originalImage);
subplot(3, 3, 2);
bar(pixelCount);
title('Histogram of original image', 'FontSize', captionFontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
grid on;

% Threshold the image to get a binary image (only 0's and 1's) of class "logical."
%Using Thresh_Tool
[thresholdValue,binaryImage] = thresh_tool(originalImage);

message = sprintf('Do you want to Invert the image?');
reply = questdlg(message, 'Invert?', 'Yes', 'No', 'No');
% Note: reply will = '' for Upper right X, 'Yes' for Yes, and 'No' for No.
if strcmpi(reply, 'Yes')
    binaryImage = originalImage < thresholdValue;
elseif strcmpi(reply,'No')
    binaryImage = originalImage > thresholdValue;
end

figure(100)
% ========== IMPORTANT OPTION ============================================================
% Use < if you want to find dark objects instead of bright objects.
%   binaryImage = originalImage < thresholdValue; % Dark objects will be chosen if you use <.

% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
binaryImage = imfill(binaryImage, 'holes');

% Show the threshold as a vertical red bar on the histogram.
hold on;
maxYValue = ylim;
line([thresholdValue, thresholdValue], maxYValue, 'Color', 'r');
% Place a text label on the bar chart showing the threshold.
annotationText = sprintf('Thresholded at %d gray levels', thresholdValue);
% For text(), the x and y need to be of the data class "double" so let's cast both to double.
text(double(thresholdValue + 5), double(0.5 * maxYValue(2)), annotationText, 'FontSize', 10, 'Color', [0 .5 0]);
text(double(thresholdValue - 70), double(0.94 * maxYValue(2)), 'Background', 'FontSize', 10, 'Color', [0 0 .5]);
text(double(thresholdValue + 50), double(0.94 * maxYValue(2)), 'Foreground', 'FontSize', 10, 'Color', [0 0 .5]);

% Display the binary image.
subplot(3, 3, 3);
imshow(binaryImage); 
title('Binary Image, obtained by thresholding', 'FontSize', captionFontSize); 

% Identify individual blobs by seeing which pixels are connected to each other.
% Each group of connected pixels will be given a label, a number, to identify it and distinguish it from the other blobs.
% Do connected components labeling with either bwlabel() or bwconncomp().
labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
% labeledImage is an integer-valued image where all pixels in the blobs have values of 1, or 2, or 3, or ... etc.
subplot(3, 3, 4);
imshow(labeledImage, []);  % Show the gray scale image.
title('Labeled Image, from bwlabel()', 'FontSize', captionFontSize);

% Let's assign each blob a different color to visually show the user the distinct blobs.
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
% coloredLabels is an RGB image.  We could have applied a colormap instead (but only with R2014b and later)
subplot(3, 3, 5);
imshow(coloredLabels);
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
caption = sprintf('Pseudo colored labels, from label2rgb().\nBlobs are numbered from top to bottom, then from left to right.');
title(caption, 'FontSize', captionFontSize);

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, originalImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);

% bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
% Plot the borders of all the coins on the original grayscale image using the coordinates returned by bwboundaries.
subplot(3, 3, 6);
imshow(originalImage);
title('Outlines, from bwboundaries()', 'FontSize', captionFontSize); 
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
hold on;
boundaries = bwboundaries(binaryImage,4);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off;

textFontSize = 14;	% Used to control size of "blob number" labels put atop the image.
labelShiftX = -7;	% Used to align the labels in the centers of the coins.
% Print header line in the command window.
fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
% Loop over all blobs printing their measurements to the command window.
meanGL=NaN(numberOfBlobs,1); blobArea=meanGL;blobPerimeter=meanGL;blobEAD=meanGL;
blobCentroid=NaN(numberOfBlobs,2);


for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
	thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
	meanGL(k) = mean(originalImage(thisBlobsPixels)); % Find mean intensity (in original image!)
	%meanGL2008a = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a
	
	blobArea(k) = blobMeasurements(k).Area;		% Get area.
	blobPerimeter(k) = blobMeasurements(k).Perimeter;		% Get perimeter.
	blobCentroid(k,:) = blobMeasurements(k).Centroid;		% Get centroid one at a time
	blobEAD(k) = 2.*((blobArea(k)./(pi)).^(0.5));					% Compute EAD - Equivalent Area Diameter.
    %%IMPORTANT: USING A=pi*r^2 --> d=2*sqrt(A/pi)
    
	%fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meanGL(k), blobArea(k), blobPerimeter(k), blobCentroid(k,:), blobECD(k,:));
	
    % Put the "blob number" labels on the "boundaries" grayscale image.
	%text(blobCentroid(k,1) + labelShiftX, blobCentroid(k,2), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold');
end
outputdata=table([1:numberOfBlobs]', meanGL, blobArea, blobPerimeter, blobCentroid, blobEAD);
outputdata.Properties.VariableNames={'Blob','Mean Intensity','Area','Perimeter','Centroid','Equivelant_Area_Diameter'};
% Now, I'll show you another way to get centroids.
% We can get the centroids of ALL the blobs into 2 arrays,
% one for the centroid x values and one for the centroid y values.
allBlobCentroids = [blobMeasurements.Centroid];
centroidsX = allBlobCentroids(1:2:end-1);
centroidsY = allBlobCentroids(2:2:end);
% Put the labels on the rgb labeled image also.
subplot(3, 3, 5);
%for k = 1 : numberOfBlobs           % Loop through all blobs.
	%text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold');
%end




% Alert user that the demo is done and give them the option to save an image.
message = sprintf('Done making measurements of the features');
message = sprintf('%s\n\nDo you want to save the pseudo-colored image?', message);
reply = questdlg(message, 'Save image?', 'Yes', 'No', 'No');
% Note: reply will = '' for Upper right X, 'Yes' for Yes, and 'No' for No.
if strcmpi(reply, 'Yes')
	% Ask user for a filename.
	FilterSpec = {'*.PNG', 'PNG Images (*.png)'; '*.tif', 'TIFF images (*.tif)'; '*.*', 'All Files (*.*)'};
	DialogTitle = 'Save image file name';
	% Get the default filename.  Make sure it's in the folder where this m-file lives.
	% (If they run this file but the cd is another folder then pwd will show that folder, not this one.
	thisFile = mfilename('fullpath');
	[thisFolder, baseFileName, ext] = fileparts(thisFile);
	DefaultName = sprintf('%s/%s.tif', thisFolder, baseFileName);
	[fileName, specifiedFolder] = uiputfile(FilterSpec, DialogTitle, DefaultName);
	if fileName ~= 0
		% Parse what they actually specified.
		[folder, baseFileName, ext] = fileparts(fileName);
		% Create the full filename, making sure it has a tif filename.
		fullImageFileName = fullfile(specifiedFolder, [baseFileName '.tif']);
		% Save the labeled image as a tif image.
		imwrite(uint8(coloredLabels), fullImageFileName);
		% Just for fun, read image back into the imtool utility to demonstrate that tool.
		tifimage = imread(fullImageFileName);
		imtool(tifimage, []);
	end
end
pause(0.5)
outputdata.Area=outputdata.Area.*(realToImageConv.^2);
outputdata.Perimeter=outputdata.Perimeter.*realToImageConv;
outputdata.Equivelant_Area_Diameter=outputdata.Equivelant_Area_Diameter.*realToImageConv;
%close all
