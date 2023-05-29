function [EEG, group_del_channel]= plot_group_deleted_chan_location(EEG,group_del_channel,save_path)
%this function plots all the deleted channel locations in on a scalp map
%Requires a EEGLAB EEG matrix, with the locations of all channels (before some got delted)
%The EEG.urchanlocs can be created using EEGLAB's chan location function.
%Requires group_del_channel=[]; before it enters the participant loop
%it should be run for several subjects on a loop
%group_del_channel will keep adding the data of the next participant in the
%loop and create a group average every time
% it overwrites the figure it creates everytime it adds a new participant

labels_all = {EEG.urchanlocs(1:64).labels}.'; %stores all the labels in a new matrix
labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
del_chan=setdiff(labels_all,labels_good); %figurs out the deleted channels
EEG.del_chan=[];
for chan=1:length(del_chan)
    for del=1:64
        if strcmp(del_chan{chan},EEG.urchanlocs(del).labels)
            EEG.del_chan = [EEG.del_chan;EEG.urchanlocs(del)]; %finds locations etc
        end
    end
end

%creating the group channels
if isempty(EEG.del_chan) %in case there is no bad one
    return
elseif isempty(group_del_channel) %in case it is the first time it is ran
    group_del_channel= EEG.del_chan;
else
    group_del_channel= [group_del_channel;EEG.del_chan]; %in case there is already data it'll add it together
end
% creating a matrix with all 64 channels and how often they have been deleted
for i=1:64
    all_del{i}=EEG.urchanlocs(i).labels;
end

channel_amounts_deleted=zeros(1,64);
for i=1:length(group_del_channel)
    for ii=1:64 %loop through every channel
        if strcmpi(group_del_channel(i).labels,all_del(ii))
            channel_amounts_deleted(ii)=channel_amounts_deleted(ii)+1; 
        end
    end
end
plot_chan_labels_2=[];
for i=1:64 %all channels
 if nonzeros(channel_amounts_deleted(i)) %this looks if it got at least once deleted
   chan_loc=EEG.urchanlocs(i); %ifso, find location info
   chan_loc.labels=channel_amounts_deleted(i); %replace name by amount deleted
   plot_chan_labels_2=[plot_chan_labels_2;chan_loc] ; %store
end
end
%% wrong way of doing it
% plot_chan_labels=group_del_channel;  
% for i=1:length(group_del_channel)
%     n_chan=0;
%     for ii=1:length(group_del_channel) %looking for each channel
%         if strcmpi(group_del_channel(i).labels,group_del_channel(ii).labels) %comparing that with each channel
%             n_chan=n_chan+1;
%         end
%     end
%     %once compared to each channel we know how often that channel happens
%     plot_chan_labels(i).labels=num2str(n_chan);
% end
% 
% %need to delete the duplicated channels, because you can't have more than 64
% for i=length(plot_chan_labels):-1:1 %look at all channels (backwards, because we are deleting stuff and we don't want a crash)
%     if plot_chan_labels(i).labels >1 %then we need to find if duplicate exist
%         for ii=length(plot_chan_labels):-1:1 %looking through all existing deleted chans (backwards, because we are deleting stuff and we don't want a crash)
%             if (plot_chan_labels(ii).urchan == plot_chan_labels(i).urchan) && ii~=i %if orginal chan loc is same AND we are sure we are NOT comparing the same with the same
%                 plot_chan_labels(i)=[]; %delete it
%                  break %need this or it'll crash once the channel is deleted, it should take care 
%             end
%         end
%     end
% end
%% plotting
if isempty(group_del_channel)
    figure('Renderer', 'painters', 'Position', [10 10 375 225]); %this is just an empty figure
elseif length(group_del_channel)==1
    plot_chan_labels_2=[plot_chan_labels_2;plot_chan_labels_2]; %need 2 to have the function work, but will just plot 2 the same one
    figure; topoplot([],plot_chan_labels_2, 'style', 'fill',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
    plot_chan_labels_2=plot_chan_labels_2(1);
else
    figure; topoplot([],plot_chan_labels_2, 'style', 'map',  'electrodes','labels', 'chaninfo', EEG.chaninfo,'maplimits' , [-2000 2000] );
    title(["Numbers represent how often that channel is deleted"])
end
print([save_path 'group_deleted_channels'], '-dpng' ,'-r300');
close all
end
