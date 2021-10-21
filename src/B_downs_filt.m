

% This defines the set of subjects
subject_list = {'12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};%
nsubj = length(subject_list); % number of subjects

% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';

% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];

        % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 256);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [],1,1690,1,[],1);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [],45,152,0,[],1);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
end;

