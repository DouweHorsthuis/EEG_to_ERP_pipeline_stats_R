function [eyetrHeatMap] = edf_to_figure(data_path)
%% edf_to_figure is a combination of functions from @EDF2Mat. 
% Edf2Mat is created by 'Adrian Etter, Marc Biedermann'
% edf_to_figure is created by Douwe John Horsthuis (2022)
% This function generates one figure with the heatmap of the gazepositions of all the data that.
% It needs the data_path (where the .EDF files are of each participant)
% 
% It only uses the Edf2Mat function and the edfimporter files in the private folder.
% However, if you want to plot something else, you might need other files
% from the original Edf2Mat folder, so they still exist but are not used

%% Merge all the data into one file
data_folder = dir(data_path);
obj.Samples.posX = [];
obj.Samples.posY = [];
amount = 0;
for i = 1:length(data_folder)
    if endsWith(data_folder(i).name, '.edf')
        amount = amount + 1;
        edf_temp = Edf2Mat([data_path data_folder(i).name]);  % Read the eye tracking files
        obj.Samples.posX = [obj.Samples.posX; edf_temp.Samples.posX];  % Combine all gaze positions
        obj.Samples.posY = [obj.Samples.posY; edf_temp.Samples.posY];  % Combine all gaze positions
    end
end

%% Calculate the rest (from Edf2Mat)
startIdx = 1;
endIdx = numel(obj.Samples.posX);
eye = 1;

range = startIdx:endIdx;
assert(numel(range) > 0, 'Edf2Mat:plot:range', ...
    'Start Index == End Index, nothing to be plotted');

%% Define variables
gaussSize = 80;
gaussSigma = 20;

posX = obj.Samples.posX(range, eye);
posY = obj.Samples.posY(range, eye);

%% Generate data for heatmap
gazedata = [posY, posX];
gazedata = gazedata(~isnan(gazedata(:, 1)), :);

% Set minimum x and y values to zero
for i = 1:size(gazedata, 2)
    gazedata(:, i) = gazedata(:, i) - min(gazedata(:, i));
end

gazedata = ceil(gazedata) + 1;
data = accumarray(gazedata, 1);
data = flipud(data);

%% Smooth the data
gaze = zeros(size(data));
cut = mean(data(:));
data(data > cut) = cut;

size_1 = gaussSize;
sigma = gaussSigma;
[Xm, Ym] = meshgrid(linspace(-.5, .5, size_1));

s = sigma / size_1;                     % Gaussian width as a fraction of imageSize
kernel = exp(-(((Xm.^2)+(Ym.^2)) ./ (2* s^2))); % Formula for 2D Gaussian

eyetrHeatMap = conv2(data, kernel, 'same');

% Map with gaze points on the value of the mean of the heatmap
gaze(data > 0) = mean(eyetrHeatMap(:));

% Calculate plot range (min to max on each axis)
plotRange = [min(posX), max(posX), min(posY), max(posY)];
if plotRange(1) < 0
    plotRange(1:2) = [0, max(posX) + abs(plotRange(1))];
end
if plotRange(3) < 0
    plotRange(3:4) = [0, max(posY) + abs(plotRange(3))];
end
plotRange = floor(plotRange);

obj.imhandle = imagesc(eyetrHeatMap);

axis(plotRange);
colorbar;
title(['Heat map of the eye movement for all ' num2str(amount) ' blocks']);
end