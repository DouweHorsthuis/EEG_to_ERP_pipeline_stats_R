% Combination of EEGLAB downsample and filter, and reject channel script by Ana on 2017-07-11
% Combined and updated by Douwe Horsthuis last updated on 12/22/2021
% ------------------------------------------------
clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'some sort of ID' 'a different id for a different particpant'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store your data';
%% info needed for this script specific
%locations
eeglab_location = 'C:\Users\wherever\eeglab2019_1\'; %needed if using a 10-5-cap
scripts_location = 'C:\\Scripts\'; %needed if using 160channel data
% filter info
downsample_to=256; % what is the sample rate you want to downsample to
lowpass_filter_hz=45; %45hz filter
lowpass_filter_order=152;%this is the suggested value produced by EEGlab
highpass_filter_hz=1; %1hz filter
highpass_filter_order=1690;%this is the suggested value produced by EEGlab
%% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];
    % Load original dataset (created by previous script)
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    %downsample
    EEG = pop_resample( EEG, downsample_to);
    EEG = eeg_checkset( EEG );
    %filtering
    EEG.filter=table(lowpass_filter_hz,lowpass_filter_order,highpass_filter_hz,highpass_filter_order); %adding it to subject EEG file
    EEG = pop_eegfiltnew(EEG, [],highpass_filter_hz,highpass_filter_order,1,[],1); % 1hz filter
    EEG = eeg_checkset( EEG );
    EEG= pop_eegfiltnew(EEG, [],lowpass_filter_hz,lowpass_filter_order,0,[],1); 
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);
    %adding channel location
    if EEG.nbchan >63 && EEG.nbchan < 95 %64chan cap (can be a lot of externals, this makes sure that it includes a everything that is under 96 channels, which could be an extra ribbon)
        EEG=pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BESA\standard-10-5-cap385.elp']); %make sure you put here the location of this file for your computer
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
        %deleting bad channels
        EEG = pop_rejchan(EEG,'elec', [1:64],'threshold',5,'norm','on','measure','kurt');
    elseif EEG.nbchan >159 && EEG.nbchan < 191 %160chan cap
        EEG=pop_chanedit(EEG, 'lookup',[scripts_location 'BioSemi160.sfp']); %make sure you put here the location of this file for your computer
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
        %deleting bad channels
        EEG = pop_rejchan(EEG,'elec', [1:160],'threshold',5,'norm','on','measure','kurt');
    end
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
end

