% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 5/21/2021
% ------------------------------------------------
eeglab
Group_list={'Control_young', 'Control_adult', 'Cystinosis_young', 'Cystinosis_adult', 'Cystinosis_parent', 'CKD'};
for gr=2:length(Group_list)
    if strcmpi(Group_list{gr},'Control_young')
    subject_list = {'10056' '10066' '10085' '10135' '10214' '10260' '10281' '10373' '10376' '10400' '10400-01' '10463' '10486' '10553' '10555' '10567' '10583' '10641' '10769' '10780' '10853' '10862' '10912' '10935' '10951' '10956'};
    elseif strcmpi(Group_list{gr},'Control_adult')
    subject_list = {'12011' '12067' '12090' '12091' '12124' '12156' '12338' '12341' '12351' '12392' '12429' '12434' '12437' '12542' '12543' '12682' '12686' '12709' '12716' '12737' '12762' '12812' '12824' '12840' '12883' '12889'};
    elseif strcmpi(Group_list{gr},'CKD')
    subject_list= {'6167' '6169' '6179' '6201' '6209' '6237' '6238' '6239' '6285' '6287' '6288' '6292'};
    elseif strcmpi(Group_list{gr},'Cystinosis_young')
    subject_list={'8103'  '8110' '8113' '8114'  '8117' '8119' '8121'  '8128'  '8129' '8136' '8145' '8148' '8150' '8157' '8158' '8159' '8161'  '8169' '8176'  '8177' '8187' '8190' '8261'  '8608'};
    elseif strcmpi(Group_list{gr},'Cystinosis_adult')
    subject_list={'9102' '9109'  '9119' '9146' '9150' '9155' '9176' '9179'  '9180' '9182' '9182-01' '9183' '9189' '9193'}; %all the IDs for the indivual particpants
    elseif strcmpi(Group_list{gr},'Cystinosis_parent')
    subject_list={'8103-01' '8110-01' '8114-01' '8121-01' '8128-01'  '8161-01' '8161-02' '8176-01' '8187-01' '8187-02' '8261-01' '9109-01' '9179-01' '9183-01'};
    else 
        disp('not possible')
        pause()
    end
        home_path    = 'D:\cystinosis visual adaptation\Data\'; %place data is (something like 'C:\data\')
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
        bad_chan = input(prompt); %
        if isempty(bad_chan) ~=1
            EEG = pop_select( EEG, 'nochannel',bad_chan);
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
        end
        close all

        %% creating figures with deleted and bridged channels
        EEG=plot_deleted_chan_location(EEG,data_path); %plotting the location of deleted chan
        % plotting a topoplot with how many channels get for everyone
        [EEG, group_del_channel]=plot_group_deleted_chan_location(EEG,group_del_channel,home_path,Group_list{gr},length(subject_list));
       
        %% group quality info, ID / % deleted data / seconds of data left / N - deleted channels
        quality(s,:)=[str2double(subject_list{s}), str2double(Group_list{gr}) EEG.deleteddata_wboundries, round(EEG.xmax), length(EEG.del_chan)];
    end
    save([home_path 'participant_info_' Group_list{gr}], 'quality');
end
