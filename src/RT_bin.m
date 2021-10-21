clear all
eeglab

% This defines the set of subjects
subject_list = {'2201','2202','2204','2207','2208','2212','2216','2217','2220','2221','2222','2223','2229','2231','2236','2237','2238','2243','2247','2250','2252','2254','2256','2257','2261','2262','2267','2274','2281','2284','2285','2286','2292','2295','2297','7003','7007','7019','7025','7046','7048','7049','7051','7054','7058','7059','7061','7063','7064','7073','7074','7075','7078','7089','7092','7123','7556','7808','10092','10130','10149','10172','10214','10360','10394','10446','10463','10476','10581','10585','10590','10640','10748','10780','10784','10862','10888','10915','10967','12004','12005','12006','12007','12012','12038','12139','12177','12188','12197','12203','12206','12215','12230','12272','12313','12328','12329','12413','12433','12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};%
name_paradigm = 'Visual_Gating' % this is needed for saving the table at the end
nsubj = length(subject_list); % number of subjects
participant_info = []; % needed for creating matrix at the end
% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';


% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];

        % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_inter.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    EEG = pop_selectevent( EEG, 'type',{'1' '101' '102' '103' '104' '105' '175' '254' '45'},'select','inverse','deleteevents','on','deleteepochs','on','invertepochs','off');
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG  = pop_binlister( EEG , 'BDF', '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\scripts\binlist_all_rt.txt', 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = pop_epochbin( EEG , [-50  2000],  [-50 0]);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_rt.set'], 'filepath', data_path); %saves data
    indv_bins = EEG.trials
    
 
    ID                         = string(subject_list{s});%keeps all the IDs
    indv_bins                  = EEG.trials
    data_subj                  = [];
    data_subj                  = [ID, indv_bins]; %combines IDs and Bad channels
    participant_info           = [participant_info; data_subj];%combine new data with old data
end;


colNames                   = {'ID','amount of clicks after 145'}; %adding names for columns
responses = array2table( participant_info,'VariableNames',colNames); %creating table with column names
save([home_path name_paradigm 'info_if_responded'], 'responses'); %saving table
    


