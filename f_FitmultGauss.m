function [tEstimate,TrialError,NumTrials]=f_FitmultGauss(numGaussians,x,y)
fontSize = 20;
% Initial Gaussian Parameters
ax=gca;
Width=NaN(numGaussians,1);
Mean=Width;
for i=1:numGaussians
    message = sprintf(strcat('Peak number ',num2str(i),' / ',num2str(numGaussians)));
    questdlg(message, 'okay?', 'Yes', 'No', 'Yes');
    peakroi=drawpoint(ax);
    widthroi=drawline(ax);
    Width(i)=abs(widthroi.Position(1,1)-widthroi.Position(2,1));%Difference in X values along line
    Mean(i)=peakroi.Position(1);%only take x-value
end
initialGuesses = [Mean, Width];
startingGuesses = reshape(initialGuesses', 1, []);

tFit = reshape(x, 1, []);
y = reshape(y, 1, []);

global c NumTrials TrialError


% Initializations
NumTrials = 0;  % Track trials
TrialError = 0; % Track errors
% t and y must be row vectors.
tFit = reshape(x, 1, []);
y = reshape(y, 1, []);

%-------------------------------------------------------------------------------------------------------------------------------------------
% Perform an iterative fit using the FMINSEARCH function to optimize the height, width and center of the multiple Gaussians.
options = optimset('TolX', 1e-4, 'MaxFunEvals', 10^12);  % Determines how close the model must fit the data
% First, set some options for fminsearch().
options.TolFun = 1e-4;
options.TolX = 1e-4;
options.MaxIter = 100000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HEAVY LIFTING DONE RIGHT HERE:
% Run optimization
[parameter, fval, flag, output] = fminsearch(@(lambda)(fitgauss(lambda, tFit, y)), startingGuesses, options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----------------------------------------------------------------------------------------------------------------
% Now plot results.
yhat = PlotComponentCurves(x, y, tFit, c, parameter);


% Make table for the fitted, estimated results.
% First make numGaussians row by 3 column matrix: Column 1 = amplitude, column 2 = mean, column 3 = width.
% 	parameter % Print to command window.
estimatedMuSigma = reshape(parameter, 2, [])';
gaussianParameters = [c, estimatedMuSigma];
% Now sort parameters in order of increasing mean
gaussianParameters = sortrows(gaussianParameters, 2);
% Create table of the output parameters and display it below the actual, true parameters.
tEstimate = table((1:numGaussians)', c(:), estimatedMuSigma(:, 1), estimatedMuSigma(:, 2), 'VariableNames', {'Number', 'Amplitude', 'Mean', 'Width'});

% Plot the error as a function of trial number.
hFigError = figure();
hFigError.Name = 'Errors';
plot(TrialError, 'b-');
% hFigError.WindowState = 'maximized';
grid on;
xlabel('Trial Number', 'FontSize', fontSize)
ylabel('Error', 'FontSize', fontSize)

caption = sprintf('Errors for all %d trials.', length(TrialError));
title(caption, 'FontSize', fontSize, 'Interpreter', 'none');

message = sprintf('Done!\nHere is the result!\nNote: there could be multiple ways\n(multiple sets of Gaussians)\nthat you could achieve the same sum (same test curve).');
fprintf('Done running %s.m.\n', mfilename);
msgbox(message);
end
%=======================================================================================================================================================
function yhat = PlotComponentCurves(x, y, t, c, parameter)
try
	fontSize = 20;
	% Get the means and widths.
	means = parameter(1 : 2 : end);
	widths = parameter(2 : 2 : end);
	% Now plot results.
	hFig2 = figure;
	hFig2.Name = 'Fitted Component Curves';
	% 	plot(x, y, '--', 'LineWidth', 2)
    % Plot original summation curve, that is the actual curve.
	bar(x,y)
	hold on;
	yhat = zeros(1, length(t));
	numGaussians = length(c);
	legendStrings = cell(numGaussians + 2, 1);
	for k = 1 : numGaussians
		% Get each component curve.
		thisEstimatedCurve = c(k) .* gaussian(t, means(k), widths(k));
		% Plot component curves.
		plot(x, thisEstimatedCurve, '-', 'LineWidth', 2);
		hold on;
		% Overall curve estimate is the sum of the component curves.
		yhat = yhat + thisEstimatedCurve;
		legendStrings{k} = sprintf('Estimated Gaussian %d', k);
	end
	
    %plot(x, y, 'r-', 'LineWidth', 1)
	% Plot estimated summation curve, that is the estimate of the curve.
	plot(x, yhat, 'k--', 'LineWidth', 2)
	grid on;
	xlabel('X', 'FontSize', fontSize)
	ylabel('Y', 'FontSize', fontSize)
	caption = sprintf('Estimation of %d Gaussian Curves that will fit data.', numGaussians);
	title(caption, 'FontSize', fontSize, 'Interpreter', 'none');
	grid on
	legendStrings{numGaussians+1} = sprintf('Actual original signal');
	legendStrings{numGaussians+2} = sprintf('Sum of all %d Gaussians', numGaussians);
	legend(legendStrings);
	xlim(sort([x(1) x(end)]));
	hFig2.WindowState = 'maximized';
	drawnow;
	
catch ME
	% Some error happened if you get here.
	callStackString = GetCallStack(ME);
	errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', ...
		mfilename, callStackString, ME.message);
	WarnUser(errorMessage);
end
end % of PlotComponentCurves


%=======================================================================================================================================================
function theError = fitgauss(lambda, t, y)
% Fitting function for multiple overlapping Gaussians, with statements
% added (lines 18 and 19) to slow the progress and plot each step along the
% way, for educational purposes.
% Author: T. C. O'Haver, 2006

global c NumTrials TrialError
try
	
	A = zeros(length(t), round(length(lambda) / 2));
	for j = 1 : length(lambda) / 2
		A(:,j) = gaussian(t, lambda(2 * j - 1), lambda(2 * j))';
	end
	
	c = A \ y';
	z = A * c;
	theError = norm(z - y');
	
	% Penalty so that heights don't become negative.
	if sum(c < 0) > 0
		theError = theError + 1000000;
	end
	
	NumTrials = NumTrials + 1;
	TrialError(NumTrials) = theError;
catch ME
	% Some error happened if you get here.
	callStackString = GetCallStack(ME);
	errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', ...
		mfilename, callStackString, ME.message);
	WarnUser(errorMessage);
end
end % of fitgauss()


%=======================================================================================================================================================
function g = gaussian(x, peakPosition, width)
%  gaussian(x,pos,wid) = gaussian peak centered on pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
%  T. C. O'Haver, 1988
% Examples: gaussian([0 1 2],1,2) gives result [0.5000    1.0000    0.5000]
% plot(gaussian([1:100],50,20)) displays gaussian band centered at 50 with width 20.
g = exp(-((x - peakPosition) ./ (0.60056120439323 .* width)) .^ 2);
end % of gaussian()

%=======================================================================================================================================================
% Gets a string describing the call stack where each line is the filename, function name, and line number in that file.
% Sample usage
% try
% 	% Some code that might throw an error......
% catch ME
% 	callStackString = GetCallStack(ME);
% 	errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', ...
% 		mfilename, callStackString, ME.message);
% 	WarnUser(errorMessage);
% end
function callStackString = GetCallStack(errorObject)
try
	theStack = errorObject.stack;
	callStackString = '';
	stackLength = length(theStack);
	% Get the date of the main, top level function:
	% 	d = dir(theStack(1).file);
	% 	fileDateTime = d.date(1:end-3);
	if stackLength <= 3
		% Some problem in the OpeningFcn
		% Only the first item is useful, so just alert on that.
		[folder, baseFileName, ext] = fileparts(theStack(1).file);
		baseFileName = sprintf('%s%s', baseFileName, ext);	% Tack on extension.
		callStackString = sprintf('%s in file %s, in the function %s, at line %d\n', callStackString, baseFileName, theStack(1).name, theStack(1).line);
	else
		% Got past the OpeningFcn and had a problem in some other function.
		for k = 1 : length(theStack)-3
			[folder, baseFileName, ext] = fileparts(theStack(k).file);
			baseFileName = sprintf('%s%s', baseFileName, ext);	% Tack on extension.
			callStackString = sprintf('%s in file %s, in the function %s, at line %d\n', callStackString, baseFileName, theStack(k).name, theStack(k).line);
		end
	end
catch ME
	errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\nError Message:\n%s', ...
		mfilename, ME.message);
	WarnUser(errorMessage);
end
end % from callStackString

%==========================================================================================================================
% Pops up a warning message, and prints the error to the command window.
function WarnUser(warningMessage)
if nargin == 0
	return; % Bail out if they called it without any arguments.
end
try
	fprintf('%s\n', warningMessage);
	uiwait(warndlg(warningMessage));
	% Write the warning message to the log file
	folder = 'C:\Users\Public\Documents\MATLAB Settings';
	if ~exist(folder, 'dir')
		mkdir(folder);
	end
	fullFileName = fullfile(folder, 'Error Log.txt');
	fid = fopen(fullFileName, 'at');
	if fid >= 0
		fprintf(fid, '\nThe error below occurred on %s.\n%s\n', datestr(now), warningMessage);
		fprintf(fid, '-------------------------------------------------------------------------------\n');
		fclose(fid);
	end
catch ME
	message = sprintf('Error in WarnUser():\n%s', ME.message);
	fprintf('%s\n', message);
	uiwait(warndlg(message));
end
end % from WarnUser()
