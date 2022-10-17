function [EEG]= plot_deleted_chan_location(EEG,save_path)
%this function plots all the deleted channel locations in on a scalp map
%Requires a EEGLAB EEG matrix, with the locations of all channels (before some got delted)
%The EEG.urchanlocs can be created using EEGLAB's chan location function. 
labels_all = {EEG.urchanlocs(1:64).labels}.'; %stores all the labels in a new matrix
labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
del_chan=setdiff(labels_all,labels_good);
EEG.del_chan=[];
for chan=1:length(del_chan)
    for del=1:64
        if strcmp(del_chan{chan},EEG.urchanlocs(del).labels)
            EEG.del_chan = [EEG.del_chan;EEG.urchanlocs(del)];
        end
    end
end
if isempty(EEG.del_chan)
    figure('Renderer', 'painters', 'Position', [10 10 375 225]); %this is just an empty figure
elseif length(EEG.del_chan)==1
    EEG.del_chan=[EEG.del_chan;EEG.del_chan]; %need 2 to have the function work, but will just plot 2 the same one
    figure; topoplot([],EEG.del_chan, 'style', 'fill',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
    EEG.del_chan=EEG.del_chan(1);
else
    figure; topoplot([],EEG.del_chan, 'style', 'fill',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
end
print([save_path EEG.subject '_deleted_channels'], '-dpng' ,'-r300');
close all
end