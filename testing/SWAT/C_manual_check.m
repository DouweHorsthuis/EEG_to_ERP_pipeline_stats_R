% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 5/21/2021
% ------------------------------------------------
eeglab
Group_list={'cystinosis' 'adult_controls'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'adult_controls')
        subject_list = {'12091' '12709' '12883'};
    elseif strcmpi(Group_list{gr},'cystinosis')
        subject_list = {'9109' '9182' '9182'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'C:\Users\douwe\Desktop\processed\'; %place data is (something like 'C:\data\')
    %need to add the folder with the functions
    file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
    addpath(genpath(file_loc));%adding path to your scripts so that the functions are found

    for s=1:length(subject_list)
        if s==1
            group_del_channel=[]; %needed for the plot_group_deleted_chan_location function
        end
        clear bad_chan;
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\'];
        EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
        pop_eegplot( EEG, 1, 1, 1);
        prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
        %%  bad_chan = input(prompt); %
        if isempty(bad_chan) ~=1
            EEG = pop_select( EEG, 'nochannel',bad_chan);
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
        end
        close all

        %% creating figures with deleted and bridged channels
        EEG=plot_deleted_chan_location(EEG,data_path); %plotting the location of deleted chan
        plotting a topoplot with how many channels get for everyone
        [EEG, group_del_channel]=plot_group_deleted_chan_location(EEG,group_del_channel,home_path,Group_list{gr},length(subject_list));

        %% group quality info, ID / % deleted data / seconds of data left / N - deleted channels
        quality(s,:)=[str2double(subject_list{s}), str2double(Group_list{gr}) EEG.deleteddata_wboundries,round(EEG.xmax), length(EEG.del_chan)];
    end
    save([home_path 'participant_info_' Group_list{gr}], 'quality');
end
