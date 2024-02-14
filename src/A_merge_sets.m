% EEGLAB merge sets, and creates .set file
% by Douwe Horsthuis updated on 2/14/2024
% ------------------------------------------------
subject_list = {'Participant_1_ID' 'Participant_2_ID'};
home_path    = 'C:\Users\whereisyourdata\'; %place data is (something like 'C:\data\')
save_path    = 'D:\wheretosaveyourdatat\'; %only for the first script, in case you load your data from somewhere special but want to save it somewhere else
readme_file  ='yes';%'yes' or 'no', if yes using [EEG]= readme_to_EEG(EEG, data_path) to read  readme file
eye_tracking ='no';%'yes' or 'no', if yes using edf_to_figure(data_path)to create a figure with avg gaze
Pausing_yn='no';%'yes' or 'no'; if you want to first only run people with one block, which is how data is usually collected in our lab, it'll pause if it finds more files
if strcmpi(readme_file,'yes') || strcmpi(eye_tracking,'yes')% if yes we need to add the functions to the file path
    file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
    addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
end
%Loop to go over each participant
for s = 1:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    save_path_indv=[save_path subject_list{s} '\'];
    %% loading particpant bdf files.
    %if participants have only 1 block, load only this one file
    filename_quick=dir([data_path '/*.BDF']);
    if size(filename_quick,1) == 1
        EEG = pop_biosig([data_path  filename_quick.name]);
    else
        for bdf_bl = 1:size(filename_quick,1)
            if strcmpi(Pausing_yn,'yes')
            disp(['too many blocks for participant ' subject_list{s}])
            pause ()
            end
            %if participants have more than one block, load the blocks in a row
            %your files need to have the same name, except for a increasing number at the end (e.g. id#_file_1.bdf id#_file_2)
            EEG = pop_biosig([data_path  filename_quick(bdf_bl).name]);
            [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        %since there are more than 1 files, they need to be merged to one big .set file.
        EEG = pop_mergeset( ALLEEG, 1:size(filename_quick,1), 0);
    end
    mkdir(save_path_indv) %if individual folders do not exist
    %adding info to the EEG structure
    if strcmpi(readme_file,'yes')
        [EEG]= readme_to_EEG(EEG, data_path);
    else
        EEG.subject = subject_list{s}; %subject ID
    end
    if strcmpi(eye_tracking,'yes')
        edf_to_figure(data_path);
        saveas(gcf,[save_path_indv subject_list{s} '_ET'])
        close all
    end
    %save the bdf as a .set file
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',save_path_indv);
end
