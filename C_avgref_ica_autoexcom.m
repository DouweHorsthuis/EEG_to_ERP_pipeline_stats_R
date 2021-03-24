% This scripts does an average reference, uses runica and IClabel to created IC components
% and defines and deletes the bad ones. The bad components also get printed.
% last edits done on by Douwe 6/29/2020
% ------------------------------------------------

clear variables


% This defines the set of subjects
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
nsubj = length(subject_list); % number of subjects

% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store all the data';
fprintf('have you manually inspected if there are channels that should have been rejected but are missed? \n If yes, hit any key to continue')
pause;
% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];
    
    
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    %Doing an average reference
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ref.set'],'filepath', data_path);
    %Will do the ICA
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'extended',1,'interupt','on'); %runs runica function
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
    %Deleting the bad components
    EEG = iclabel(EEG); %does ICLable function
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    ICA_components(:,8) = sum(ICA_components(:,[2 3 4 5 6]),2); %row 2 = muscle row 3= eye row 6 = channel noise, combining this makes sure that the component also gets deleted if its a combination of the 3.
    bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.05); %if the new row is over 80% of the component and the component has less the 5% brain
    %will plot all the IC components that get deleted
    figure
    if bad_components > 0 %script would stop if people lack bad components
        pop_topoplot(EEG, 0, [bad_components] ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
        title(subject_list{s});
        print([home_path subject_list{s} '_Bad_ICs_topos'], '-dpng');
        EEG = pop_subcomp( EEG, bad_components, 0); %excluding the bad components
    else %instead of only plotting bad components it will plot all components
        pop_topoplot(EEG, 0, [1:length(ICA_components)] ,subject_list{s},[ceil(sqrt(length(ICA_components))) ceil(sqrt(length(ICA_components)))] ,0,'electrodes','on');
        title(subject_list{s});
        print([home_path subject_list{s} '_no_bad_ICs_topos'], '-dpng');
    end
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
   
    
end;



