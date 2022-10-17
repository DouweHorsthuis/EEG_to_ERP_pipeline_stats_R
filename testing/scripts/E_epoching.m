% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 6/21/2020
% This script epochs the data
% it deletes the noisy epochs.
% it creates ERPs
% It creates a matrix with how much data it deletes at the end.
% it can also record the RTs and put them in and excel, but it needs folder after the homepath called \All RT files\
clear variables
eeglab
%% Subject info for each script
subject_list = {'6209' '6239' '8103' '8110' '8110-01' '8113' '8117' '8119' '8121' '8121-01' '8128' '8128-01'}; %all the IDs for the indivual particpants
home_path    = 'C:\Users\dohorsth\Desktop\cued-boss\'; %place data is (something like 'C:\data\')
%% info needed for this script specific 
name_paradigm = 'cued_boss'; % this is needed for saving the table at the end
%participant_info_temp = []; % needed for creating matrix at the end
binlist_location = 'C:\Users\dohorsth\Documents\GitHub\EEG_to_ERP_pipeline_stats_R\testing\scripts\'; %binlist should be named binlist.txt
binlist_name='binlist_main_rts.txt';
epoch_time = [-50 800];
baseline_time = [-50 0];
n_bins=9;% enter here the number of bins in your binlist
load([home_path 'participant_info'], 'participant_badchan');
participant_info_temp = string(zeros(length(subject_list), 3+n_bins)); %prealocationg space for speed
%% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
    %epoching
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
    %the following line creates an excel with RTs. For this to be possible make sure you have the right events in your eventlist.
    RT = pop_rt2text(ERP, 'eventlist',1, 'filename', [data_path subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
    for i=1:length(participant_badchan)
      if strcmpi(participant_badchan(i,1),subject_list{s}) 
         participant_info_temp(i,:)= [participant_badchan(i,:),percent_deleted, ERP.ntrials.accepted  ];
      end
    end
end
colNames                   = [{'ID','Deleted channels', '%data deleted'} ERP.bindescr]; %adding names for columns [ERP.bindescr] adds all the name of the bins
participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
save([home_path name_paradigm '_participant_info'], 'participant_info');



