% Combination of EEGLAB downsample and filter, and reject channel script by Ana on 2017-07-11
% Combined and updated by Douwe Horsthuis last updated on 3/1/2022
% ------------------------------------------------
clear variables
eeglab
%% Subject info for each script
% This defines the set of subjects
subject_list = {'12377' '12494' '12565' '12666' '12675'};
% Path to the parent folder, which contains the data folders for all subjects
home_path  = {'D:\OpticalFlow_sfari\' 'D:\ASSR_oddball\' 'D:\Beep-Flash_sfari\' 'D:\F.A.S.T. Response task\' 'D:\IllusoryContours_sfari\' 'D:\Restingstate_eyetracking\' };
%% info needed for this script specific
%locations
eeglab_location = 'C:\Users\douwe\OneDrive\Documents\MATLAB\eeglab2021.1\'; %needed if using a 10-20
scripts_location = 'C:\Users\douwe\OneDrive\Documents\Github\EEG_to_ERP_pipeline_stats_R\testing\scripts\'; %needed if using 160channel data
% filter info
downsample_to=256; % what is the sample rate you want to downsample to
lowpass_filter_hz=45; %45hz filter
highpass_filter_hz=1; %1hz filter
%% looping through all paradigms
for paradigm=1:length(home_path)
    %% Loop through all subjects
    for s=1:length(subject_list)
        if paradigm==5 && strcmp(subject_list{s},'12666') %illusionary contours
            disp("skipping 12666")
            continue
        end
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path{paradigm} subject_list{s} '\\'];
        % Load original dataset (created by previous script)
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        if paradigm==1 %need new chan locs for mobi data
            %loading a file with the right channel names
            EEG = pop_loadset('filename','12494.set','filepath','D:\\Beep-Flash_sfari\\12494\\');
            %deleting externals to make them both 64 (mobi data has no externals for now)
            EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            %copying the channels from the first one to the mobi one
            EEG = pop_editset(EEG, 'run', [], 'chanlocs', '{ ALLEEG(1).chanlocs ALLEEG(1).chaninfo ALLEEG(1).urchanlocs }');
            %clear ALLEEG
        else
            EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
        end
        EEG = eeg_checkset( EEG );
        
        %getting some basic info before pre-processing (avg ampl 3x, length in sec, channels
        EEG.info=table(mean(EEG.data(33,:)), mean(EEG.data(48,:)), mean(EEG.data(28,:)), EEG.xmax, {{EEG.chanlocs.labels}},  'VariableNames',{'Avg Ampl FPz', 'Avg Ampl Cz', 'Avg Ampl Iz', 'full amount of time in sec', 'channels'},'RowNames',{'Before pre-processing'}); %creating table with column names);
        EEG.subject = subject_list{s};
        %downsample
        EEG = pop_resample( EEG, downsample_to);
        EEG = eeg_checkset( EEG );
        %filtering
        EEG.filter=table(lowpass_filter_hz,highpass_filter_hz); %adding it to subject EEG file
        %EEG = pop_eegfiltnew(EEG, [],highpass_filter_hz,highpass_filter_order,1,[],1);
        EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_hz);
        EEG = eeg_checkset( EEG );
        %EEG= pop_eegfiltnew(EEG, [],lowpass_filter_hz,lowpass_filter_order,0,[],1);
        EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_hz);
        EEG = eeg_checkset( EEG );
        % EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);
        %adding channel location
        if EEG.nbchan >63 && EEG.nbchan < 95 %64chan cap (can be a lot of externals, this makes sure that it includes a everything that is under 96 channels, which could be an extra ribbon)
            %EEG=pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BESA\standard-10-5-cap385.elp']); %make sure you put here the location of this file for your computer
            EEG=pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BEM\elec\standard_1005.elc'],'eval','chans = pop_chancenter( chans, [],[]);'); %make sure you put here the location of this file for your computer and recenteres the head
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
            %deleting bad channels
            %EEG = pop_rejchan(EEG,'elec', [1:64],'threshold',5,'norm','on','measure','kurt');
            EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        elseif EEG.nbchan >159 && EEG.nbchan < 191 %160chan cap
            EEG=pop_chanedit(EEG, 'lookup',[scripts_location 'BioSemi160.sfp']); %make sure you put here the location of this file for your computer
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
            %deleting bad channels
            %EEG = pop_rejchan(EEG,'elec', [1:160],'threshold',5,'norm','on','measure','kurt');
            EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        end
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
end

