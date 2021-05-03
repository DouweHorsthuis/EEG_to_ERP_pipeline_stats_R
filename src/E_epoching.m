% EEGLAB and ERPlab epoching script by Douwe Horsthuis on6/18/2020
% This script epochs and deletes the noisy epochs.
% It creates a matrix with how much data it deletes at the end.
% it can also record the RTs and put them in and excel, but it needs a
% folder after the homepath called \All RT files\

clear variables
eeglab

% This defines the set of subjects
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
name_paradigm = 'name'; % this is needed for saving the table at the end
nsubj = length(subject_list); % number of subjects
participant_info_temp = []; % needed for creating matrix at the end
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store your data\';
eventlist_location = 'the folder where you stored your eventlist\'; %event list should be named event.txt
epoch_time = [-50 400];
baseline_time = [-50 0];
% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];
    
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_inter.set'], 'filepath', data_path);
    %epoching
    EEG = eeg_checkset( EEG );
    EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', [eventlist_location 'events.txt'], 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning', 'off' ); %here it reads in eventlist so it knows what to eppoch.
    EEG = eeg_checkset( EEG );
    EEG = pop_epochbin( EEG , epoch_time,  baseline_time); %epoch size and baseline size
    EEG = eeg_checkset( EEG );
    %cleaning (need erplab plugin for this)
    EEG= pop_artmwppth( EEG , 'Channel',  1:64, 'Flag',  1, 'Threshold',  120, 'Twindow', epoch_time, 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
    percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
    EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
    ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath', data_path);
    ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '.erp'], 'filename', [subject_list{s} '.erp'], 'filepath', data_path); %saving a.ERP file
    %the following line creates an excel with RTs. For this to be possible make sure you have the right events in your eventlist.
    %values = pop_rt2text(ERP, 'eventlist',1, 'filename', [home_path '\All RT files\' subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
    
    ID                         = string(subject_list{s});
    data_subj                  = [];
    data_subj                  = [ID, percent_deleted, ERP.EVENTLIST.trialsperbin]; %ERP.EVENTLIST.trialsperbin gives all the trials per bin
    participant_info_temp      = [participant_info_temp; data_subj];
end;
colNames                   = [{'ID','%data deleted'} ERP.bindescr]; %adding names for columns [ERP.bindescr] adds all the name of the bins
participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
save([home_path name_paradigm '_participant_epoching_cleaing_bin_info_' type_epoch], 'participant_info');



