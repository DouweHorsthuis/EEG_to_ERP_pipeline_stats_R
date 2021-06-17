% This scripts does an average reference, uses runica and IClabel to created IC components
% and defines and deletes the bad ones. The bad components also get printed.
% last edits done on by Douwe 5/11/2021
% ------------------------------------------------

clear variables

% This defines the set of subjects
subject_list = {'some sort of ID' 'a different id for a different particpant'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'the main folder where you store all the data';
figure_path = 'the main folder where you store all the ic figures';
components = num2cell(zeros(length(subject_list), 8)); %prealocationg space for speed
for s=1:length(subject_list)
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
    clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
    %Deleting the bad components
    data_path  = [home_path subject_list{s} '\\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_ica.set'], 'filepath', data_path);
    EEG = iclabel(EEG); %does ICLable function
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
    bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.05); %if the new row is over 80% of the component and the component has less the 5% brain
    brain_ic = length(find(ICA_components(:,1)>0.80));
    muscle_ic = length(find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05));
    eye_ic = length(find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05));
    hearth_ic = length(find(ICA_components(:,4)>0.80 & ICA_components(:,1)<0.05));
    line_noise_ic = length(find(ICA_components(:,5)>0.80 & ICA_components(:,1)<0.05));
    channel_ic = length(find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05));
    other_ic = length(find(ICA_components(:,7)>0.80 & ICA_components(:,1)<0.05));
    %will plot all the IC components that get deleted
    if isempty(bad_components)~= 1 %script would stop if people lack bad components
        if ceil(sqrt(length(bad_components))) == 1
            pop_topoplot(EEG, 0, [bad_components bad_components] ,subject_list{s} ,0,'electrodes','on');
        else
            pop_topoplot(EEG, 0, [bad_components] ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
        end
        title(subject_list{s});
        print([figure_path subject_list{s} '_Bad_ICs_topos'], '-dpng');
        EEG = pop_subcomp( EEG, [bad_components], 0); %excluding the bad components
    else %instead of only plotting bad components it will plot all components
        pop_topoplot(EEG, 0, 1:length(ICA_components) ,subject_list{s},[ceil(sqrt(length(ICA_components))) ceil(sqrt(length(ICA_components)))] ,0,'electrodes','on');
        title(subject_list{s});
        print([figure_path subject_list{s} '_no_bad_ICs_topos'], '-dpng');
    end
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
    subj_comps=[subject_list(s), num2cell(brain_ic), num2cell(muscle_ic), num2cell(eye_ic), num2cell(hearth_ic), num2cell(line_noise_ic), num2cell(channel_ic), num2cell(other_ic)];
    components(s,:)=[subj_comps];
    
end
save([home_path 'components'], 'components');

