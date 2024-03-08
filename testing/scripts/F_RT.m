% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 2/9/2024
% This adds all the RTs together
% You get a file with the IDs,group,Condition,RTs
% it requires that the .erp file has been created using a binlist that
% stores reaction times
clear variables
eeglab
Group_RT=[]; % is needed to store the data of all the groups together

%% info needed for this script specific
%participant_info_temp = []; % needed for creating matrix at the end
binlist_location = 'C:\Users\douwe\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\SWAT\'; %binlist should be named binlist.txt
binlist_name='binlistRT.txt';
epoch_time = [-50 500]; %time in ms e.g. [-50 100]
baseline_time = [-50 0]; %time in ms e.g. [-50 0]
n_bins=2;% enter here the number of bins in your binlist

%add here all the names of your groups, this script can give you group plots
Group_list={'controls' 'cystinosis'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'cystinosis' )
        subject_list = { '9182' '9182' '9109'};
    elseif strcmpi(Group_list{gr},'controls')
        subject_list = {'12709' '12091'  '12883'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'C:\Users\douwe\Desktop\processed_new\'; %place data is (something like 'C:\data\')
 %place data is (something like 'C:\data\')
    save_path = 'C:\Users\douwe\Desktop\processed_new\'; %where to save the participants excel files with RTs
     %need to add the folder with the functions
    file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
    addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
    participant_info_temp = string(zeros(length(subject_list), 6+n_bins)); %prealocationg space for speed
    load([home_path 'participant_info_' Group_list{gr} '.mat']);
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '/'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
        %% Doing the same as the Epoching script but now for the RT bins
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
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoched_RT.set'],'filepath', data_path);
        ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '_RT.erp'], 'filename', [subject_list{s} '_RT.erp'], 'filepath', data_path); %saving a.ERP file
        for i=1:size(quality,1)
            if strcmpi(num2str(quality(i,1)),subject_list{s})
                participant_info_temp(i,:)= [quality(i,:),percent_deleted, ERP.ntrials.accepted  ];
            end
        end
        %% This is the reaction time part
        RT = pop_rt2text(ERP, 'eventlist',1, 'filename', [save_path subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
        %collect RT per bin
        for b= 1:size(ERP.bindescr,2) %looking at all the bins (all should be RT bins)
            clear  RT_temp subject cond group; %completely get rid of these, they confuse the grouping process
            RT_temp(:,4)=num2cell(RT.EVENTLIST.bdf(b).rt) ; %this is the file that will dicate the length of all the other files. Is the all the RTs per bin as a row
            for q = 1:length(RT_temp) %adding the same variable for the lenght of the variable RT_temp
                subject{q} = subject_list{s};
                cond{q}    = RT.EVENTLIST.bdf(b).description;
                group{q}   = Group_list{gr};
            end
            RT_temp(:,1)=subject;
            RT_temp(:,2)=group;
            RT_temp(:,3)=cond;
            Group_RT=[Group_RT;RT_temp];
        end
    end
    participant_info_temp(:,2)=Group_list{gr};
    colNames                   = [{'ID','Group','% auto deleted', 'Length dataset (sec)', 'Deleted channels', '%data deleted ERP'} ERP.bindescr]; %adding names for columns [ERP.bindescr] adds all the name of the bins
    participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
    save([home_path 'participant_info_' Group_list{gr} '_RT'], 'participant_info', 'quality');
end
filename_table = [home_path 'RTs.xlsx' ];
writecell(Group_RT, filename_table); %saving excel with everyones info
save([home_path 'participant_RT'], 'Group_RT'); %saving matlab file with everyones info

