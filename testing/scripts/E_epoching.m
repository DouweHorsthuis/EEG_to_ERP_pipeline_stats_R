% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 6/21/2020
% This script epochs the data
% it deletes the noisy epochs.
% it creates ERPs
% It creates a matrix with how much data it deletes at the end.
% it can also record the RTs and put them in and excel, but it needs folder after the homepath called \All RT files\
clear variables
eeglab
%% Subject info for each script
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
    %% info needed for this script specific
    name_paradigm = 'Visual_gating'; % this is needed for saving the table at the end
    %participant_info_temp = []; % needed for creating matrix at the end
    binlist_location = 'D:\cystinosis visual adaptation\Scripts\'; %binlist should be named binlist.txt
    binlist_name='binlist.txt';
    epoch_time = [-50 400];
    baseline_time = [-50 0];
    n_bins=9;% enter here the number of bins in your binlist
    load([home_path 'participant_info_' Group_list{gr} '.mat']);
    participant_info_temp = string(zeros(length(subject_list), 4+n_bins)); %prealocationg space for speed
    %% Loop through all subjects
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '/'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
        %wrong triggers and stuff.
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
        %the following line creates an excel with RTs. For this to be possible make sure you have the right events in your eventlist.
        %RT = pop_rt2text(ERP, 'eventlist',1, 'filename', [data_path subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
        for i=1:length(quality)
            if strcmpi(num2str(quality(i,1)),subject_list{s})
                participant_info_temp(i,:)= [quality(i,:),percent_deleted, ERP.ntrials.accepted  ];
            end
        end
    end
    participant_info_temp(:,14)=num2str(str2double(participant_info_temp(:,13))- str2double(participant_info_temp(:,12)));
    participant_info_temp(:,2)=Group_list{gr};
    colNames                   = [{'ID','Group','% auto deleted', 'Length dataset (sec)', 'Deleted channels', '%data deleted ERP'} ERP.bindescr, {'misses'}]; %adding names for columns [ERP.bindescr] adds all the name of the bins
    participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
    save([home_path 'participant_info_' Group_list{gr}], 'participant_info');
end


