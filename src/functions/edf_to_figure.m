function [eyetrHeatMap] = edf_to_figure(data_path)
%% edf_to_figure is a combination of functions from @EDF2Mat.
% Edf2Mat is created by 'Adrian Etter, Marc Biedermann'
% edf_to_figure is created by Douwe John Horsthuis (2022)
% This function generates one figure with the heatmap of the gaze positions of all the data.
% It needs the data_path (where the .EDF files are of each participant)
% It needs the screen ratio of the screen the partiicpant was looking e.g. [16:10]

%% Merge all the data into one file
data_folder = dir(data_path);
obj = struct('Samples', struct('posX', [], 'posY', [])); % Initialize obj
amount = 0;

for i = 1:length(data_folder)
    if endsWith(data_folder(i).name, '.edf')
        amount = amount + 1;
        edf_temp = Edf2Mat([data_path filesep data_folder(i).name]); % Reading the eye tracking files
        obj.Samples.posX = [obj.Samples.posX; edf_temp.Samples.posX]; % Combining all of them
       obj.Samples.posY = [obj.Samples.posY; edf_temp.Samples.posY]; % Combining all of them
    end
end
exist edf_temp;
if ans == 0
    disp('No EDF file, creating empty figure')
    figure;

    title(['This participant did not have an EDF file']);
    xlabel(['This is an empty placeholder']);
elseif ans==1
    %% Perform the rest (from Edf2Mat)
    startIdx = 1;
    endIdx = numel(obj.Samples.posX);
    eye = 1;

    range = startIdx:endIdx;
    if numel(range) <= 0
        error('Edf2Mat:plot:range', 'Start Index == End Index, nothing to be plotted');
    end

    %% Variables
    gaussSize = 80;
    gaussSigma = 20;

    posX = obj.Samples.posX(range, eye);
    posY = obj.Samples.posY(range, eye);

    %% Generate data for heatmap
    gazedata = [posY, posX];
    

    % Set minimum x and y to zero
%     for i = 1:size(gazedata, 2)
%         gazedata(:, i) = gazedata(:, i) - min(gazedata(:, i));
%     end

    %finding screen size
    for i = 1:length(edf_temp.RawEdf.FEVENT)
        if  contains(edf_temp.RawEdf.FEVENT(i).codestring, 'MESSAGEEVENT')
        if  contains(edf_temp.RawEdf.FEVENT(i).message, 'DISPLAY_COORDS')
            display_coords= str2num(edf_temp.RawEdf.FEVENT(i).message(end-9:end));
        end
        end
    end
%turning all gazes outsized of screen size to NaN
    for i = 1:size(gazedata, 1)
        if   gazedata(i, 1) < 0 || gazedata(i, 2) < 0
        gazedata(i, :) = [NaN, NaN];
        elseif gazedata(i, :) > [display_coords(2),display_coords(1)]
            gazedata(i, :) = [NaN, NaN];
        elseif gazedata(i, 1) > [display_coords(2)]
            gazedata(i, :) = [NaN, NaN];
        elseif gazedata(i, 2) > [display_coords(1)]
             gazedata(i, :) = [NaN, NaN];
        end
    end
    gazedata = gazedata(~isnan(gazedata(:, 1)), :);

    gazedata = ceil(gazedata) + 1;
    data = accumarray(gazedata, 1, [max(gazedata(:, 1)), max(gazedata(:, 2))]);
    data = flipud(data);

    %% Smooth the Data
    cut = mean(data(:));
    data(data > cut) = cut;

    size_1 = gaussSize;
    sigma = gaussSigma;
    [Xm, Ym] = meshgrid(linspace(-.5, .5, size_1));

    s = sigma / size_1; % Gaussian width as fraction of imageSize
    kernel = exp(-(((Xm.^2) + (Ym.^2)) ./ (2 * s^2))); % Formula for 2D gaussian

    eyetrHeatMap = conv2(data, kernel, 'same');

    % Map with gaze points on the value of the mean of the heatmap
    gaze = mean(eyetrHeatMap(data > 0));
    % Calculate percentage of eye tracking time
    total_time = numel(range);
    eye_tracking_time = sum(~isnan(posX));
    eye_tracking_percentage = (eye_tracking_time / total_time) * 100;
    if isempty(eyetrHeatMap)
        disp('EDF File is empty')
        figure;

        title(['This participant has no data inside the eyetracking file']);
        xlabel(['This is an empty placeholder']);
    else
        % Create figure
        figure;
        imagesc(eyetrHeatMap);
        %changing range by using the pixel of the screen the subject looked at
        plotRange=[0 display_coords(1) 0 display_coords(2)];
        axis(plotRange);
        colorbar;
        title(['Heat map of the eye movement for all ' num2str(amount) ' blocks']);
        xlabel(['Percentage of Eye Tracking Time: ' num2str(eye_tracking_percentage) '%']);
    end
end
end
