eeglab

% This defines the set of subjects
subject_list = {'12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};

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
    EEG = pop_loadset('filename', [subject_list{s} '_ref.set'], 'filepath', data_path);%loads _ref file
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'extended',1,'interupt','on'); %runs runica function
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
    EEG = iclabel(EEG); %does ICLable function
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    bad_components_muscle = find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05); %if component has 80% muscle and 5% or less brain
    bad_components_eye = find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05);%if component has 80% eye and 5% or less brain
    bad_components_Channel_Noise = find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05);%if component has 80% channel noise and 5% or less brain
    BC = [ bad_components_muscle; bad_components_eye; bad_components_Channel_Noise];%combining the bad components
    EEG = pop_subcomp( EEG, BC, 0); %excluding the bad components
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
    eeglab redraw;
end;
