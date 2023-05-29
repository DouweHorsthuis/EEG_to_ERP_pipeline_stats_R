% Combination of EEGLAB downsample and filter, and reject channel script by Ana on 2017-07-11
% Combined and updated by Douwe Horsthuis last update 11/5/2021
% ------------------------------------------------
clear variables
eeglab
% This defines the set of subjects
subject_list = {'6209' '6239' '8103' '8110' '8110-01' '8113' '8117' '8119' '8121' '8121-01' '8128' '8128-01'}; %all the IDs for the indivual particpants
home_path    = 'C:\Users\dohorsth\Desktop\cued-boss\'; %place data is (something like 'C:\data\')
downsample_to=256; % what is the sample rate you want to downsample to
lowpass_filter_hz=45; %45hz filter
highpass_filter_hz=1; %1hz filter
avg_deleted_data=zeros(1, length(subject_list));
clean_data={'y'}; % if 'y' not only channels but also noisy moments in thedata get cleaned
individual_plots='yes';
if strcmpi(individual_plots,'yes')% if yes we need to add the functions to the file path
file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
end
% Loop through all subjects
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\\'];
    % Load original dataset (created by previous script)
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
    EEG = eeg_checkset( EEG );
    %getting some basic info before pre-processing (avg ampl 3x, length in sec, channels
    EEG.info=table(mean(EEG.data(33,:)), mean(EEG.data(48,:)), mean(EEG.data(28,:)), EEG.xmax, {{EEG.chanlocs.labels}},  'VariableNames',{'Avg Ampl FPz', 'Avg Ampl Cz', 'Avg Ampl Iz', 'full amount of time in sec', 'channels'},'RowNames',{'Before pre-processing'}); %creating table with column names);
    EEG.subject = subject_list{s};
    %downsample
    EEG = pop_resample( EEG, downsample_to);
    EEG = eeg_checkset( EEG );
    %filtering
    EEG.filter=table(lowpass_filter_hz,highpass_filter_hz); %adding it to subject EEG file
    EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_hz);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_hz);
    EEG = eeg_checkset( EEG );
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);

    EEG.old_n_chan = EEG.nbchan;
    old_samples=EEG.pnts;
    %adding channel location
    if EEG.nbchan >63 && EEG.nbchan < 95 %64chan cap (can be a lot of externals, this makes sure that it includes a everything that is under 96 channels, which could be an extra ribbon)
        EEG=pop_chanedit(EEG, 'lookup',[fileparts(which('eeglab')) '\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp'],'rplurchanloc',[1]); %make sure you put here the location of this file for your computer
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
        %looking for bridged channel
        if strcmpi(individual_plots,'yes')
            EEG=plotting_bridged_channels(EEG, data_path); %plotting the location of bridged chan
        end
        close all
        %deleting bad channels
        %EEG = pop_rejchan(EEG,'elec', [1:64],'threshold',5,'norm','on','measure','kurt');
        EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
        if strcmp(clean_data, 'y')
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',35,'WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
        else
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
        end
        EEG.deleteddata_wboundries=100-EEG.pnts/old_samples*100;
    elseif EEG.nbchan >159 && EEG.nbchan < 191 %160chan cap
        EEG=pop_chanedit(EEG, 'lookup',[[fileparts(matlab.desktop.editor.getActiveFilename),filesep] 'BioSemi160.sfp']); %make sure you put here the location of this file for your computer
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
        %deleting bad channels
        %EEG = pop_rejchan(EEG,'elec', [1:160],'threshold',5,'norm','on','measure','kurt');
        EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
        if strcmp(clean_data, 'y')
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',5,'WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
        else
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
        end
        EEG.deleteddata_wboundries=100-EEG.pnts/old_samples*100;
    end
    disp([num2str(EEG.deleteddata_wboundries) '% of the data got deleted for this participant']);
    avg_deleted_data(s)=EEG.deleteddata_wboundries;
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
end
disp(['on averages ' num2str(sum(avg_deleted_data)/length(subject_list)) ' % of the data got deleted']);
