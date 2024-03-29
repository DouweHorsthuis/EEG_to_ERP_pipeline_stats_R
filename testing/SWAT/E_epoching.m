% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 6/21/2020
% This script epochs the data
% it deletes the noisy epochs.
% it creates ERPs
% It creates a matrix with how much data it deletes at the end.
% it can also record the RTs and put them in and excel, but it needs folder after the homepath called \All RT files\
clear variables
eeglab
%% Subject info for each script
Group_list={ 'adult_controls' };
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'cystinosis' )
        subject_list = { '9182' '9182' '9109'};
    elseif strcmpi(Group_list{gr},'adult_controls')
        subject_list = {'12709' '12091'  '12883'};
    elseif strcmpi(Group_list{gr},'grn')
        subject_list = {'id_1' 'id_2'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'C:\Users\douwe\Desktop\processed\'; %place data is (something like 'C:\data\')
    %% info needed for this script specific
    name_paradigm = 'SWAT'; % this is needed for saving the table at the end
    %participant_info_temp = []; % needed for creating matrix at the end
    binlist_location = 'C:\Users\douwe\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\SWAT\'; %binlist should be named binlist.txt
    binlist_name_1='binlistV1.txt';
    binlist_name_2='binlistV2.txt';
    epoch_time = [-50 500]; %time in ms e.g. [-50 100]
    baseline_time = [-50 0]; %time in ms e.g. [-50 0]
    n_bins=3;% enter here the number of bins in your binlist
    load([home_path 'participant_info_' Group_list{gr} '.mat']);
    participant_info_temp = string(zeros(length(subject_list), 6+n_bins)); %prealocationg space for speed
    %% Loop through all subjects
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '/'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);

        %swat specific version finder. We use a loop to see if trigger 251 =
        %version 1 or 252 = version 2 is used first. This will give the problem
        %that you will find participants for which there is no trigger present.
        %This might be the best reason not to use the extra cleaning in script B.
        for x=1:30 %it should be in the first 30 triggers because the only reason it could not be the first one is that boundries have appeard
            if strcmp(EEG.event(x).type, '251')
                binlist_name =binlist_name_1;
            elseif strcmp(EEG.event(x).type, '252')
                binlist_name =binlist_name_2;
            end
        end

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
        for i=1:size(quality,1)
            if strcmpi(num2str(quality(i,1)),subject_list{s})
                participant_info_temp(i,:)= [quality(i,:),percent_deleted, ERP.ntrials.accepted  ];
            end
        end
    end
    %this is not needed for now, because we used it to take the total -
    %hits to figure out the misses ( or something like that) but now we
    %only look at hits.
%     participant_info_temp(:,14)=num2str(str2double(participant_info_temp(:,13))- str2double(participant_info_temp(:,12)));
    participant_info_temp(:,2)=Group_list{gr};
    colNames                   = [{'ID','Group','% auto deleted', 'Length dataset (sec)', 'Deleted channels', '%data deleted ERP'} ERP.bindescr]; %adding names for columns [ERP.bindescr] adds all the name of the bins
    participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
    save([home_path 'participant_info_' Group_list{gr}], 'participant_info');
end


