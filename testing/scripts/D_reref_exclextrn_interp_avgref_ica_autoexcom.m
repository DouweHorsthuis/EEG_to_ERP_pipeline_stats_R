% This scripts allows you to re-reference to any channel including externals
% it deletes the externals
% does an average reference
% uses runica to do an Independent Component Analysis
% uses IClabel to define the eye component
% Deletes these and the components also get printed.
% by Douwe Horsthuis updated on 5/29/2023
% ------------------------------------------------
clear variables
eeglab
% This defines the set of subjects
subject_list = {'9109' '9182' '9183' '12091' '12709' '12883'};
home_path    = 'C:\Users\douwe\Desktop\processed_new\'; %this will be teh homepath where the data will be stored and this will be used in each script onwards
%% info needed for this script specific
refchan = { }; %if you want to re-ref to a channel add the name of the channel here, if empty won't re-ref to any specific channel (for example {'EXG3' 'EXG4'} or {'Cz'})
only_eye_ic='No'; %'yes' or 'no' : if you want to delete only eye components 'yes' if you want more 'no' see line 73 for more info
%% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    
    %re-referencing, if refchan is empty this get's skipped
    if isempty(refchan)~=1 %if no re-reference channels chose this gets skipped
        for j=1:length(EEG.chanlocs)
            if strcmp(refchan{1}, EEG.chanlocs(j).labels)
                ref1=j; %stores here the index of the first ref channel
            end
        end
        if length(refchan) ==1
            EEG = pop_reref( EEG, ref1); % re-reference to the channel if there is only one input)
        elseif length(refchan) ==2 %if 2 re-ref channels are chosen it needs to find the second one
            for j=1:length(EEG.chanlocs)
                if strcmp(refchan{2}, EEG.chanlocs(j).labels)
                    ref2=j;
                end
            end
            EEG = pop_reref( EEG, [ref1 ref2]); %re-references to the average of 2 channels
        end
    end
    EEG = eeg_checkset( EEG );
    pca = EEG.nbchan-1; %the PCA part of the ICA needs stops the rank-deficiency
    EEG_inter = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);%loading participant file with all channels
    EEG_inter = pop_select( EEG_inter,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
    labels_all = {EEG_inter.chanlocs.labels}.'; %stores all the labels in a new matrix
    labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
    disp(EEG.nbchan); %writes down how many channels are there
    EEG = pop_interp(EEG, EEG_inter.chanlocs, 'spherical');%interpolates the data
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_inter.set'], 'filepath', data_path); %saves data
    disp(EEG.nbchan) %should print full amount of channels
    clear EEG_inter
    %another re-ref to the averages as suggested for the ICA
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ref.set'],'filepath', data_path);
    %Independent Component Analysis
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',pca); %using runica function, with the PCA part
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
    %organizing components
    clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
    EEG = iclabel(EEG); %does ICLable function
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    %Only the eyecomponent will be deleted, thus only components 3 will be put into the 8 component
    if strcmpi(only_eye_ic,'yes')
    ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
    bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.10); %if the new row is over 80% of the component and the component has less the 5% brain
    elseif strcmpi(only_eye_ic,'no')
    ICA_components(:,8) = sum(ICA_components(:,[2 3 4 5 6]),2);
    bad_components = (find((ICA_components(:,8)>0.70) & ICA_components(:,1)<0.10)); %if the sum of all the potential bad compontens is >70 % and brain component makes up < 10 of the componenten, mark it as bad
    else
    error('not correctly selected how many ICs should be deleted')
    end
    %Plotting all eye componentes and all remaining components
    if isempty(bad_components)~= 1 %script would stop if people lack bad components
        if ceil(sqrt(length(bad_components))) == 1
            pop_topoplot(EEG, 0, [bad_components bad_components] ,subject_list{s} ,0,'electrodes','on');
        else
            pop_topoplot(EEG, 0, bad_components ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
        end
        title(subject_list{s});
        print([data_path subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
        EEG = pop_subcomp( EEG, bad_components, 0); %excluding the bad components
        close all
    else %instead of only plotting bad components it will plot all components
        title(subject_list{s}); text( 0.2,0.5, 'there are no eye-components found')
        print([data_path subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
    end
    title(subject_list{s});
    pop_topoplot(EEG, 0, 1:size(EEG.icaweights,1) ,subject_list{s},[ceil(sqrt(size(EEG.icaweights,1))) ceil(sqrt(size(EEG.icaweights,1)))] ,0,'electrodes','on');
    print([data_path subject_list{s} '_remaining_ICs_topos'], '-dpng' ,'-r300');
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
%     %this part saves all the bad channels + ID numbers
%     lables_del = setdiff(labels_all,labels_good); %only stores the deleted channels
%     All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings
%     ID                         = string(subject_list{s});%keeps all the IDs
%     data_subj                  = [ID, All_bad_chan]; %combines IDs and Bad channels
%     participant_badchan(s,:)     = data_subj;%combine new data with old data
end
%save([home_path 'participant_badchan'], 'participant_badchan');