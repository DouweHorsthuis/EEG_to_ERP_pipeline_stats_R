% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 6/21/2020
% This script epochs the data
% it deletes the noisy epochs.
% it creates ERPs
% It creates a matrix with how much data it deletes at the end.
clear variables
eeglab
%% info needed for this script specific
name_paradigm = 'SWAT'; % this is needed for saving the table at the end
%participant_info_temp = []; % needed for creating matrix at the end
binlist_location = 'C:\Users\douwe\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\SWAT\'; %binlist should be named binlist.txt
binlist_name='binlistV1.txt';
epoch_time = [-50 500]; %time in ms e.g. [-50 100]
    baseline_time = [-50 0]; %time in ms e.g. [-50 0]
    n_bins=3;% enter here the number of bins in your binlist

%add here all the names of your groups, this script can give you group plots
Group_list={'cystinosis'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'Controls' )
        subject_list = {'12091' '12709' '12883'};
    elseif strcmpi(Group_list{gr},'cystinosis')
        subject_list = {'9109' '9182' '9183'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'C:\Users\douwe\Desktop\processed_new\'; %place data is (something like 'C:\data\')
    %need to add the folder with the functions
    file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
    addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
    participant_info_temp = string(zeros(length(subject_list), 6+n_bins)); %prealocationg space for speed
    load([home_path 'participant_info_' Group_list{gr} '.mat']);
    %% Loop through all subjects
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '/'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
       
        %epoching
        EEG = eeg_checkset( EEG );
        EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        EEG = eeg_checkset( EEG );
        EEG  = pop_binlister( EEG , 'BDF', [binlist_location binlist_name], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
        EEG = eeg_checkset( EEG );
        EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
        EEG = eeg_checkset( EEG );
        %deleting bad epochs (need erplab plugin for this)
        EEG= pop_artmwppth( EEG , 'Channel', 1:EEG.nbchan, 'Flag',  1, 'Threshold',  120, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
        percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
        EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
        %creating ERPS and saving files
        ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched.set'],'filepath', data_path);
        ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '.erp'], 'filename', [subject_list{s} '.erp'], 'filepath', data_path); %saving a.ERP file
        for i=1:size(quality,1)
            if strcmpi(num2str(quality(i,1)),subject_list{s})
                participant_info_temp(i,:)= [quality(i,:),percent_deleted, ERP.ntrials.accepted  ];
            end
        end
    end
    participant_info_temp(:,2)=Group_list{gr};
    colNames                   = [{'ID','Group','% auto deleted', 'Length dataset (sec)', 'Deleted channels', '%data deleted ERP'} ERP.bindescr]; %adding names for columns [ERP.bindescr] adds all the name of the bins
    participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
    save([home_path 'participant_info_' Group_list{gr}], 'participant_info', 'quality');
end


