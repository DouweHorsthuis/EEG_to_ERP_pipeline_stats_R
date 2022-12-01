function [EEG]=plotting_bridged_channels(EEG, save_path)
%function plots the locations of all bridged channels and saves it as a png file
%Requires a EEGLAB EEG matrix, with the locations of all channels
%Requires a path where it should save the figure
%should be ran before you delete bad channels
EEG_temp=EEG;
for i=1:length(EEG.nbchan)%delete the externals
    EEG_temp = pop_select( EEG_temp, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
end
bridge=eBridge(EEG_temp); %uses this functions to calculated bridges
EEG_temp.bridged=[];
for chan=1:bridge.Bridged.Count
    for del=1:length(EEG_temp.chanlocs)
        if ~contains(bridge.Bridged.Labels{1, chan},'EXG') %skipping externals
            if strcmp(bridge.Bridged.Labels{1, chan}  ,EEG_temp.chanlocs(del).labels)
                EEG_temp.bridged = [EEG_temp.bridged;EEG_temp.chanlocs(del)];
            end
        end
    end
end
if isempty(EEG_temp.bridged)
    figure('Renderer', 'painters', 'Position', [10 10 375 225])%this is just an empty figure
elseif length(EEG_temp.bridged)==1
    EEG_temp.bridged = [EEG_temp.bridged;EEG_temp.bridged]; %need 2 to have the function work, but will just plot 2 the same one
    figure; topoplot([],EEG_temp.bridged, 'style', 'fill',  'electrodes', 'labelpoint', 'chaninfo', EEG_temp.chaninfo);
    EEG_temp.bridged=EEG_temp.bridged(1);
else
    figure; topoplot([],EEG_temp.bridged, 'style', 'fill',  'electrodes', 'labelpoint', 'chaninfo', EEG_temp.chaninfo);
end
if isempty(bridge.Bridged.Labels{1, 1})
    bridge.Bridged.Labels='Nothing is bridged';
else
    bridge.Bridged.Labels=strjoin(bridge.Bridged.Labels);
end
saveas(gcf,[save_path EEG_temp.subject '_bridged_channels'])
close all
EEG.bridged=EEG_temp.bridged;
end