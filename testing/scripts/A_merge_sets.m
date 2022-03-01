% EEGLAB merge sets, and creates .set file
% by Douwe Horsthuis updated on 2/22/2022
% ------------------------------------------------
clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\Restingstate_eyetracking\';
%% info needed for this script specific
filename     = 'rest_et'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
blocks       = 3; % the amount of BDF files. if different participant have different amounts of blocks, run those participant separate
%% Loop through all subjects
for s = 1:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  subject_list{s} '_' filename '.bdf'])
    if blocks == 1
        %if participants have only 1 block, load only this one file
        EEG = pop_biosig([data_path  subject_list{s} '_' filename '.bdf']);
    else
        for bdf_bl = 1:blocks
            %if participants have more than one block, load the blocks in a row
            %your files need to have the same name, except for a increasing number at the end (e.g. id#_file_1.bdf id#_file_2)
            EEG = pop_biosig([data_path  subject_list{s} '_' filename '_' num2str(bdf_bl) '.bdf']);
            [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        %since there are more than 1 files, they need to be merged to one big .set file.
        EEG = pop_mergeset( ALLEEG, 1:blocks, 0);
    end
    %adding info to the EEG structure
    EEG.subject = subject_list{s}; %subject ID
    %save the bdf as a .set file
    
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end
