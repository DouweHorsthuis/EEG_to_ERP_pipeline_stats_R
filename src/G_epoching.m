clear all
eeglab

% This defines the set of subjects
subject_list = {'12329' '2252' '2261' '2243' '12707' '2254' '12512' '2217' '2256' '2247' '2262' '10214'}; % {'2201','2202','2204','2207','2208','2212','2216','2217','2220','2221','2222','2223','2229','2231','2236','2237','2238','2243','2247','2250','2252','2254','2256','2257','2261','2262','2267','2274','2281','2284','2285','2286','2292','2295','2297','7003','7007','7019','7025','7046','7048','7049','7051','7054','7058','7059','7061','7063','7064','7073','7074','7075','7078','7089','7092','7123','7556','7808','10092','10130','10149','10172','10214','10360','10394','10446','10463','10476','10581','10585','10590','10640','10748','10780','10784','10862','10888','10915','10967','12004','12005','12006','12007','12012','12038','12139','12177','12188','12197','12203','12206','12215','12230','12272','12313','12328','12329','12413','12433','12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};%
name_paradigm = 'Visual_Gating' % this is needed for saving the table at the end
nsubj = length(subject_list); % number of subjects
participant_info_temp = []; % needed for creating matrix at the end
% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';


% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];

        % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_inter_2.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List', '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\scripts\events.txt', 'SendEL2', 'EEG', 'UpdateEEG', 'codelabel', 'Warning', 'off' );
    EEG = eeg_checkset( EEG );
    EEG = pop_epochbin( EEG , [-50  400],  [-50 0]);
    EEG = eeg_checkset( EEG );
    EEG= pop_artmwppth( EEG , 'Channel',  1:64, 'Flag',  1, 'Threshold',  120, 'Twindow', [ -50 400], 'Windowsize',  200, 'Windowstep',  200 );% to flag bad epochs
    percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100 %looks for the length of all the epochs that should be deleted / length of all epochs * 100
    EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
    ERP = pop_averager( EEG , 'Criterion', 1, 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_all.set'],'filepath', data_path);
    ERP = pop_savemyerp(ERP, 'erpname', [subject_list{s} '_all.erp'], 'filename', [subject_list{s} '_all.erp'], 'filepath', data_path);
    %values = pop_rt2text(ERP, 'eventlist',1, 'filename', ['\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\All RT files\' subject_list{s} '_all_rt.xls'], 'header', 'on', 'listformat', 'basic' );
    ID                         = string(subject_list{s});
    data_subj                  = [];
    data_subj                  = [ID, percent_deleted];
    participant_info_temp      = [participant_info_temp; data_subj];
end;
colNames                   = {'ID','%data deleted'}; %adding names for columns
participant_info = array2table( participant_info_temp,'VariableNames',colNames); %creating table with column names
save([home_path name_paradigm '_participant_epoching_cleaing_info_extra_clean'], 'participant_info');
    


