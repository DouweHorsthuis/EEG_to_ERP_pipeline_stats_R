% this scripts interpolates channels using the _downft.set file and the excom file. It
% creates a matrix with all the previously deleted channels. Created by
% Douwe Horsthuis last update on 6/22/2021
clear variables
eeglab
close all
subject_list = {'some sort of ID' 'a different id for a different particpant'}; % This defines the set of subjects
name_paradigm = 'name'; % this is needed for saving the table at the end
%participant_info = []; % needed for creating matrix at the end
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store your data';
participant_badchan = string(zeros(length(subject_list), 2)); %prealocationg space for speed
% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    clear labels_all labels_good lables_del data_subj
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} ''];
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);%loading participant file with 64 channels
    %deleting externals
    EEGinter = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
    labels_all = {EEGinter.chanlocs.labels}.'; %stores all the labels in a new matrix
    EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path); %loads latest pre-proc file
    labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
    disp(EEG.nbchan); %writes down how many channels are there
    EEG = pop_interp(EEG, EEGinter.chanlocs, 'spherical');%interpolates the data
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_inter.set'], 'filepath', data_path); %saves data
    disp(EEG.nbchan) %should print 64
    
    %this part saves all the bad channels + ID numbers
    lables_del = setdiff(labels_all,labels_good); %only stores the deleted channels
    All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings
    ID                         = string(subject_list{s});%keeps all the IDs
    data_subj                  = [ID, All_bad_chan]; %combines IDs and Bad channels
    participant_badchan(s,:)     = data_subj;%combine new data with old data
end
save([home_path name_paradigm '_participant_interpolation_info'], 'participant_badchan');