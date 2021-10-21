% this scripts interpolates using the exext.set file and the excom file. It
% creates a matrix with all the deleted channels. Created by Douwe Horsthuis on 5/7/2020
clear all
eeglab

% This defines the set of subjects
subject_list = {'12329' '2252' '2261' '2243' '12707' '2254' '12512' '2217' '2256' '2247' '2262' '10214'}; %'2201','2202','2204','2207','2208','2212','2216','2217','2220','2221','2222','2223','2229','2231','2236','2237','2238','2243','2247','2250','2252','2254','2256','2257','2261','2262','2267','2274','2281','2284','2285','2286','2292','2295','2297','7003','7007','7019','7025','7046','7048','7049','7051','7054','7058','7059','7061','7063','7064','7073','7074','7075','7078','7089','7092','7123','7556','7808','10092','10130','10149','10172','10214','10360','10394','10446','10463','10476','10581','10585','10590','10640','10748','10780','10784','10862','10888','10915','10967','12004','12005','12006','12007','12012','12038','12139','12177','12188','12197','12203','12206','12215','12230','12272','12313','12328','12329','12413','12433','12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};%
name_paradigm = 'Visual_Gating' % this is needed for saving the table at the end
nsubj = length(subject_list); % number of subjects
participant_info = []; % needed for creating matrix at the end
% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';


% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} ''];
    
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exext.set'], 'filepath', data_path);%loading participant file with 64 channels
    labels_all = [];
    labels_all = {EEG.chanlocs.labels}.'; %stores all the labels in a new matrix
    [ALLEEG EEG index] = eeg_store( ALLEEG, EEG, 1); %store specified EEG dataset(s) in the ALLEG variable
    index = index +1; %creates new index (it might overwrite it otherwise, but not sure)
    EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path); %loads latest pre-proc file
    labels_good = [];
    labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
    disp(EEG.nbchan); %writes down how many channels are there
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG index] = eeg_store( ALLEEG, EEG, index); %store specified EEG dataset(s) in the ALLEG variable
    EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');%interpolates the data
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_inter.set'], 'filepath', data_path); %saves data
    disp(EEG.nbchan) %should print 64 
    
    %this part saves all the bad channels + ID numbers
    lables_del = [];
    lables_del = setdiff(labels_all,labels_good); %only stores the deleted channels
    All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings 
    ID                         = string(subject_list{s});%keeps all the IDs
    data_subj                  = [];
    data_subj                  = [ID, All_bad_chan]; %combines IDs and Bad channels
    participant_info           = [participant_info; data_subj];%combine new data with old data
end;
save([home_path name_paradigm '_participant_interpolation_info'], 'participant_info');



