% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 2/14/2024
% ------------------------------------------------
eeglab
plot_individual = 'yes'; %yes or no if, do you want a plot with deleted channels per participant
plot_group = 'yes';%yes or no if, do you want a plot with deleted channels per group
%add here all the names of your groups, this script can give you group plots
Group_list={'Name_grp1' 'Name_grp2'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'Name_grp1')
        subject_list = {'ID_1' 'ID_2'};
    elseif strcmpi(Group_list{gr},'Name_grp2')
        subject_list = {'ID_3' 'ID_4'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'D:\whereisthedata\'; %place data is (something like 'C:\data\')
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
        %% fixing stuff with weird triggers
        %% check 1 - sometimes triggers have a numer above 1000
        % in this case we can simply subract 63488, which get added due to
        % a hardware issue
        wrong_trigger='no';
        for i = 1:30 %checking the first 30 triggers, to make sure we don't check boundries and other things only by mistake
            if contains(EEG.event(i).type, 'boundary') %skipping the boundary events
                continue
            elseif str2double(EEG.event(i).type) > 1000  %there are triggers with 63488 added to them
                wrong_trigger='yes';

            end
        end
        if strcmp(wrong_trigger,'yes') %there are wrong triggers
            for i=1:length(EEG.event) %go over all the events
                if contains(EEG.event(i).type, 'boundary') %skipping the boundary events
                    continue
                else
                    EEG.event(i).type = num2str(str2double(EEG.event(i).type)-63488); %subtrackt the number that has been added by mistake
                end
            end
        else
            %% check 2 - EEGLAB issue where some triggers get called for example "condition 1" while others are called "1"
            % we fix this by looking inside the EEG.event structure and making
            % it uniform for each participant
            for i =1:length(EEG.event)%something odd, where eeg.event is irregular
                if contains(EEG.event(i).type, 'boundary') %skipping the boundary events
                    continue
                elseif ~isempty(EEG.event(i).edftype)
                    EEG.event(i).type = char(num2str(EEG.event(i).edftype)); %making sure that the edf are fixed first
                else
                    new=EEG.event(i).type;
                    EEG.event(i).edftype=str2double(new); %fixing edftype
                end
            end
        end
        pop_eegplot( EEG, 1, 1, 1);
        prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
        bad_chan = input(prompt); %
        if isempty(bad_chan) ~=1
            EEG = pop_select( EEG, 'nochannel',bad_chan);
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
        end
        close all

        %% creating figures with deleted and bridged channels
        if strcmpi(plot_individual, 'yes')
            EEG=plot_deleted_chan_location(EEG,data_path); %plotting the location of deleted chan
        else
            %To know which channels got deleted so we are
            %storing that happens in the function otherwise
            labels_all = {EEG.urchanlocs(1:64).labels}.'; %stores all the labels in a new matrix
            labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
            del_chan=setdiff(labels_all,labels_good); %looks for the difference
            EEG.del_chan=[];
            for chan=1:length(del_chan) %loop for each deleted channel
                for del=1:64 %across all 64 original channels
                    if strcmp(del_chan{chan},EEG.urchanlocs(del).labels) %we need to know the location
                        EEG.del_chan = [EEG.del_chan;EEG.urchanlocs(del)]; %combining everything and storing it in the EEG file
                    end
                end
            end
        end
        if strcmpi(plot_group, 'yes')
            % plotting a topoplot with how many channels get for everyone
            [EEG, group_del_channel]=plot_group_deleted_chan_location(EEG,group_del_channel,home_path,Group_list{gr},length(subject_list));
        end
        %% group quality info, ID / % deleted data / seconds of data left / N - deleted channels
        quality(s,:)=[str2double(subject_list{s}), str2double(Group_list{gr}) EEG.deleteddata_wboundries,round(EEG.xmax), length(EEG.del_chan)];
    end
    save([home_path 'participant_info_' Group_list{gr}], 'quality');
end
