% EEGLAB merge sets, and creates .set file
% by Douwe Horsthuis updated on 6/21/2021
% ------------------------------------------------
subject_list = {'6209' '6239' '8103' '8103-01' '8110' '8110-01' '8113' '8117' '8119' '8121' '8121-01' '8128' '8128-01'}; %all the IDs for the indivual particpants
subject_list ={ '8128-01'}
home_path    = 'C:\Users\dohorsth\Desktop\cued-boss\'; %place data is (something like 'C:\data\')
filename     = 'cued_boss'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
blocks       = 1; % the amount of BDF files. if different participant have different amounts of blocks, run those participant separate
readme_file  ='yes';%'yes' or 'no', if yes using [EEG]= readme_to_EEG(EEG, data_path) to read  readme file
eye_tracking ='no';%'yes' or 'no', if yes using edf_to_figure(data_path)to create a figure with avg gaze
if strcmpi(readme_file,'yes') || strcmpi(eye_tracking,'yes')% if yes we need to add the functions to the file path
file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
end
for s = 1:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  subject_list{s} '_' filename '.bdf'])
    if blocks == 1
        %if participants have only 1 block, load only this one file
        EEG = pop_biosig([data_path  subject_list{s} '_' filename '_1.bdf']);
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
    if strcmpi(readme_file,'yes')
    [EEG]= readme_to_EEG(EEG, data_path);
    else
    EEG.subject = subject_list{s}; %subject ID
    end
    if strcmpi(eye_tracking,'yes')
        edf_to_figure(data_path);
        saveas(gcf,[data_path subject_list{s} '_ET'])
        close all
    end
    %save the bdf as a .set file
    
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end
