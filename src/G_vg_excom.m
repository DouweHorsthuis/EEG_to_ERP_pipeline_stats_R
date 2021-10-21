%auto excom script, uses data pre-proccessed in EEGLAB that has been run
%through the runica function. selects bad components, takes in
%consideration brain data<5%. Created on 5/21/2020 by Douwe Horsthuis

clear all
eeglab

% This defines the set of subjects
subject_list = {};
nsubj = length(subject_list); % number of subjects

% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';
participant_info_temp = [];
% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];

    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_ica.set'], 'filepath', data_path);%load
    EEG = iclabel(EEG); %Labels all ICA components into categories
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    bad_components_muscle = find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05); %if component has 80% muscle and 5% or less brain
    bad_components_eye = find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05);%if component has 80% eye and 5% or less brain
    bad_components_Channel_Noise = find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05);%if component has 80% channel noise and 5% or less brain
    BC = [ bad_components_muscle; bad_components_eye; bad_components_Channel_Noise];%combining the bad components
    EEG = pop_subcomp( EEG, BC, 0); %excluding the bad components
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
    
    bad_eye                    = length(bad_components_eye);                         % creating a
    bad_muscle                 = length(bad_components_muscle);                      % matrix that
    bad_channel                = length(bad_components_Channel_Noise);               % keeps all
    ID                         = string(subject_list{s});                            % the info
    colNames                   = {'ID','N Eye Comp','N Muscle Comp','N Chan_noise'}; % of deleted
    data_subj                  = [ID, bad_eye, bad_muscle, bad_channel];             % ICA components
    bad_ICA_components_temp         = [bad_ICA_components_temp; data_subj];
    bad_ICA_components = array2table( bad_ICA_components_temp,'VariableNames',colNames);
    
    eeglab redraw;
end

save([home_path name_paradigm '_bad_ICA_components'], 'bad_ICA_components');


