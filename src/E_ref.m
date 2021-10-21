eeglab

% This defines the set of subjects
subject_list = {'12313','12328','12329','12413','12433','12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};

% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';

% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];

        % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ref.set'],'filepath', data_path);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
end;

