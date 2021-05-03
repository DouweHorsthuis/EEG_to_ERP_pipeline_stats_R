% Combination of EEGLAB downsample and filter, Exclude external and reject channel script by Ana on 2017-07-11
% combined by Douwe on 6/18/2020
% ------------------------------------------------

% This defines the set of subjects
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
nsubj = length(subject_list); % number of subjects
eeglab_location = 'C:\Users\wherever\eeglab2019_1\'
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store your data';

% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];

        % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    %downsample
    EEG = pop_resample( EEG, 256); %downsample to 256hz
    EEG = eeg_checkset( EEG );
    %filtering
    EEG = pop_eegfiltnew(EEG, [],1,1690,1,[],1); % 1hz filter
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [],45,152,0,[],1); %45hz filter
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);
    %excluding externals
    EEG=pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BESA\standard-10-5-cap385.elp']); %make sure you put here the location of this file for your computer
    EEG = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exext.set'],'filepath', data_path);
    %auto channel rejection
    EEG = eeg_checkset( EEG );
    EEG = pop_rejchan(EEG ,'threshold',5,'norm','on','measure','kurt');
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end;

