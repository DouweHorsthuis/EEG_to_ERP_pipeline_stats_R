% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 5/21/2021
% ------------------------------------------------
subject_list = {'some sort of ID' 'a different id for a different particpant'};
home_path  = 'the main folder where you store your data';

group_del_channel=[]; %needed for the plot_group_deleted_chan_location function
for s=1:length(subject_list)
    clear bad_chan;
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    pop_eegplot( EEG, 1, 1, 1);
    prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
    bad_chan = input(prompt); %
    if isempty(bad_chan) ~=1
        EEG = pop_select( EEG, 'nochannel',bad_chan);
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    close all

    %% creating figures with deleted and bridged channels
    EEG=plot_deleted_chan_location(EEG,data_path); %plotting the location of deleted chan
    % plotting a topoplot with how many channels get for everyone
    [EEG, group_del_channel]=plot_group_deleted_chan_location(EEG,group_del_channel,home_path);
%% group quality info, ID / % deleted data / seconds of data left / N - deleted channels
    quality(s,:)=[str2double(subject_list{s}), EEG.deleteddata_wboundries,round(EEG.xmax), length(EEG.del_chan)];
end
load([home_path 'participant_info']) %so we can add 
save([home_path 'participant_info'], 'participant_badchan', 'quality');
