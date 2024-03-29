% Created on 8/27/2018 By Douwe Horsthuis
% Last update 6/22/2021
% Script will take the pre-proccesed and epoched data and transfer for each trial a mean for time window of interest to a non matlab file (to be loaded in different softwares (such as R studio)
% 1)create the means of the epoched data, for a defined time window, for a selected channel
% 2)asign a number to the condition (can have up to 3 conditions)
% 3)assign a trial number to every individual mean
% 4)assign a number for what group the participants belong to (can have up to 4 group)
% 5)transfers this to an txt, dat, csv, xls, xlsm, xlsx or xlsb

clear EEG
eeglab
close all

group = 4; %Add here how many groups of participant you have, 4 is max
load_path  = 'D:\whereisthedata\';
save_path= 'D:\wheretosavethedata\';
typefile= '.xlsx';% final file can be saved as mat, txt, dat, csv, xls, xlsm, xlsx or xlsb
time_window = [startime endtime];%specify the begin and end points of the time window of interest in ms either a specific point for N1/MMN/P2
name_timewindow= 'name';%name timewindow of intresset
chan = 'channelname'; %channel of interest O1
name_file = '_epoched'; %the name after the IDnumber (excluding .set)
events_in_epoch_cond1 = bin1number; % what bins you want see EEG.EVENTLIST.eventinfo.binlabel or EEG.EVENTLIST.eventinfo.code eg. 101
events_in_epoch_cond2 = bin2number; % what bins you want see EEG.EVENTLIST.eventinfo.binlabel or EEG.EVENTLIST.eventinfo.code eg. 102
events_in_epoch_cond3 = bin3number; % what bins you want see EEG.EVENTLIST.eventinfo.binlabel or EEG.EVENTLIST.eventinfo.code eg. 103
events_in_epoch_cond4 = bin4number; % what bins you want see EEG.EVENTLIST.eventinfo.binlabel or EEG.EVENTLIST.eventinfo.code eg. 104
events_in_epoch_cond5 = bin5number; % what bins you want see EEG.EVENTLIST.eventinfo.binlabel or EEG.EVENTLIST.eventinfo.code eg. 105
%% variables and matrices that need to exist %%
prev_subjects = 0; %needs this to calculate how many subjects existed in previous groups
data_subj = [];
data_subj_small = [];
prompt1 = 'are your individual data files in a subject folder or in one main folder? (1-individual folders 2-main folder)';
data_folders = input(prompt1);
prompt2 = 'How many conditions have you defined?';
n_conditions = input(prompt2);
for j=1:group %running it per group
    if group > 4
        disp('you can have a maximum of 4 groups')
        return
    end
    if j==1 %group 1
        subj    =  {'id_1' 'id_2'};
        if isempty(subj)
            disp('you forgot to input subject IDs for group 1');
            return
        end
    elseif j==2 %group 2
        subj    = {'id_1' 'id_2'};
        if isempty(subj) && group > 1
            disp('you forgot to input subject IDs for group 2');
            return
        end
    elseif j==3
        subj    = {'id_1' 'id_2'};
        if isempty(subj) && group > 2
            disp('you forgot to input subject IDs for group 3');
            return
        end
    elseif j==4
        subj    ={'id_1' 'id_2'};
        if isempty(subj) && group > 3
            disp('you forgot to input subject IDs for group 4');
            return
        end
    end
    data_temp = [];
    for subj_count = 1:length(subj)
        %% loading data and separating the epochs
        % Path to the folder containing the current Subject's data
        if data_folders == 1
            data_path  = [load_path subj{subj_count} '\'];
        elseif data_folders == 2
            data_path  = load_path;
        end
        %loading data set
        EEG  = pop_loadset('filename', [subj{subj_count} name_file '.set'], 'filepath', data_path , 'loadmode', 'all');

        % separating the epochs
        if isfield (EEG.event, 'edftype')%check if EDFtype exist
            epochtype = 'edftype';
            if isa(events_in_epoch_cond2,'cell') %they have been turned into this because of previous participant, need to turn back into double
                events_in_epoch_cond1 = str2double(events_in_epoch_cond1);
                events_in_epoch_cond2 = str2double(events_in_epoch_cond2);
                events_in_epoch_cond3 = str2double(events_in_epoch_cond3);
                events_in_epoch_cond4 = str2double(events_in_epoch_cond4);
                events_in_epoch_cond5 = str2double(events_in_epoch_cond5);
            end

        else
            epochtype = 'type';
            if isa(events_in_epoch_cond2,'double')
                events_in_epoch_cond1 = {num2str(events_in_epoch_cond1)};
                events_in_epoch_cond2 = {num2str(events_in_epoch_cond2)};
                events_in_epoch_cond3 = {num2str(events_in_epoch_cond3)};
                events_in_epoch_cond4 = {num2str(events_in_epoch_cond4)};
                events_in_epoch_cond5 = {num2str(events_in_epoch_cond5)};
            end
        end
        if n_conditions == 1
            EEGcond1  = pop_selectevent( EEG, epochtype,events_in_epoch_cond1,'deleteevents','on','deleteepochs','on','invertepochs','off');
            if subj_count==1 && j ==1
                pop_eegplot( EEGcond1, 1, 1, 1);
                disp('press a button to continue')
                pause
            end
            EEGcond2 = [];
            EEGcond3 = [];
            EEGcond4 = [];
            EEGcond5 = [];
        elseif n_conditions == 2
            disp('define epoch info for condition 1')
            EEGcond1 = pop_selectevent( EEG, epochtype,events_in_epoch_cond1,'deleteevents','on','deleteepochs','on','invertepochs','off');
            if subj_count==1 && j ==1
                pop_eegplot( EEGcond1, 1, 1, 1);
                disp('press a button to continue')
                pause
            end
            disp('define epoch info for condition 2')
            EEGcond2 = pop_selectevent( EEG, epochtype,events_in_epoch_cond2,'deleteevents','on','deleteepochs','on','invertepochs','off');
            EEGcond3 = [];
            EEGcond4 = [];
            EEGcond5 = [];
        elseif n_conditions == 3
            disp('define epoch info for condition 1')
            EEGcond1 = pop_selectevent( EEG, epochtype,events_in_epoch_cond1,'deleteevents','on','deleteepochs','on','invertepochs','off');
            if subj_count==1 && j ==1
                pop_eegplot( EEGcond1, 1, 1, 1);
                disp('press a button to continue')
                pause
            end
            disp('define epoch info for condition 2')
            EEGcond2 = pop_selectevent( EEG, epochtype,events_in_epoch_cond2,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 3')
            EEGcond3 = pop_selectevent( EEG, epochtype,events_in_epoch_cond3,'deleteevents','on','deleteepochs','on','invertepochs','off');
            EEGcond4 = [];
            EEGcond5 = [];
        elseif n_conditions == 4
            disp('define epoch info for condition 1')
            EEGcond1 = pop_selectevent( EEG, epochtype,events_in_epoch_cond1,'deleteevents','on','deleteepochs','on','invertepochs','off');
            if subj_count==1 && j ==1
                pop_eegplot( EEGcond1, 1, 1, 1);
                disp('press a button to continue')
                pause
            end
            disp('define epoch info for condition 2')
            EEGcond2 = pop_selectevent( EEG, epochtype,events_in_epoch_cond2,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 3')
            EEGcond3 = pop_selectevent( EEG, epochtype,events_in_epoch_cond3,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 4')
            EEGcond4 = pop_selectevent( EEG, epochtype,events_in_epoch_cond4,'deleteevents','on','deleteepochs','on','invertepochs','off');
            EEGcond5 = [];
        elseif n_conditions == 5
            disp('define epoch info for condition 1')
            EEGcond1 = pop_selectevent( EEG, epochtype,events_in_epoch_cond1,'deleteevents','on','deleteepochs','on','invertepochs','off');
            if subj_count==1 && j ==1
                pop_eegplot( EEGcond1, 1, 1, 1);
                disp('press a button to continue')
                pause
            end
            disp('define epoch info for condition 2')
            EEGcond2 = pop_selectevent( EEG, epochtype,events_in_epoch_cond2,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 3')
            EEGcond3 = pop_selectevent( EEG, epochtype,events_in_epoch_cond3,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 4')
            EEGcond4 = pop_selectevent( EEG, epochtype,events_in_epoch_cond4,'deleteevents','on','deleteepochs','on','invertepochs','off');
            disp('define epoch info for condition 5')
            EEGcond5 = pop_selectevent( EEG, epochtype,events_in_epoch_cond5,'deleteevents','on','deleteepochs','on','invertepochs','off');


        end
        %% looking for the channel of intressed
        for i= 1:length(EEG.chanlocs)
            if strcmp(chan,EEG.chanlocs(i).labels)
                chan= EEG.chanlocs(i).urchan; %changes the name of the chan to the index number
            end
        end
        clear cond1_tr cond2_tr cond3_tr cond4_tr cond5_tr Trial = [];  %
        %% creating means for amplitude for a specific channel
        % find the samples within this time window for condition 1
        samplecond1 = find( EEGcond1.times>=time_window(1) & EEGcond1.times<=time_window(2) );
        % pull out the data from this range of samples, and average over samples for condition 1 (creating the ERP)
        meanscond1 = squeeze( mean( EEGcond1.data( chan, samplecond1, : ), 2 ) );
        con1 = 0; con1(1:length(meanscond1))= 1; %so we can find what samples are condition 1
        cond1_tr = (1:length(meanscond1)); %this creates an index for each trial

        %do the same condition 2, but first check if it exists
        if isempty(EEGcond2)~= 1
            samplescond2 = find( EEGcond2.times>=time_window(1) & EEGcond2.times<=time_window(2) );
            meanscond2 = squeeze( mean( EEGcond2.data( chan, samplescond2, : ), 2 ) );
            cond2 = 0; cond2(1:length(meanscond2)) = 2;
            cond2_tr = (1:length(meanscond2));
        else
            cond2= []; cond2_tr = []; meanscond2=[];
        end
        %do the same for condition 3, but first check if it exists
        if isempty(EEGcond3)~= 1
            samplescond3 = find( EEGcond3.times>=time_window(1) & EEGcond3.times<=time_window(2) );
            meanscond3 = squeeze( mean( EEGcond3.data( chan, samplescond3, : ), 2 ) );
            cond3 = 0; cond3(1:length(meanscond3))    = 3;
            cond3_tr = (1:length(meanscond3)) ;
        else
            cond3= []; cond3_tr = []; meanscond3 = [];
        end
        %do the same for condition 4, but first check if it exists
        if isempty(EEGcond4)~= 1
            samplescond4 = find( EEGcond4.times>=time_window(1) & EEGcond4.times<=time_window(2) );
            meanscond4 = squeeze( mean( EEGcond4.data( chan, samplescond4, : ), 2 ) );
            cond4 = 0; cond4(1:length(meanscond4))    = 4;
            cond4_tr = (1:length(meanscond4)) ;
        else
            cond4= []; cond4_tr = []; meanscond4 = [];
        end
        %do the same for condition 5, but first check if it exists
        if isempty(EEGcond5)~= 1
            samplescond5 = find( EEGcond5.times>=time_window(1) & EEGcond5.times<=time_window(2) );
            meanscond5 = squeeze( mean( EEGcond5.data( chan, samplescond5, : ), 2 ) );
            cond5 = 0; cond5(1:length(meanscond5))    = 5;
            cond5_tr = (1:length(meanscond5)) ;
        else
            cond5= []; cond5_tr = []; meanscond5 = [];
        end
        Condition= [con1, cond2, cond3, cond4, cond5]; %combining the conditions into 1 matrix
        if isrow(Condition); Condition = Condition'; end
        Trial = [cond1_tr, cond2_tr, cond3_tr, cond4_tr, cond5_tr]; %combining the trials into 1 matrix
        if isrow(Trial); Trial = Trial'; end
        Erp = [meanscond1; meanscond2; meanscond3; meanscond4; meanscond5]; %combining the ERPs of each condition into 1 matrix
        %% Subject - calls all of them the total n of subjects not individ ID
        clear subject
        subject =1:length(Erp);
        subject(1:length(Erp))      = subj_count;
        if isrow(subject); subject = subject'; end
        prev_subjects= length(subj)+prev_subjects;
        %% combining
        clear data_subj_small
        data_subj_small = [subject, Condition, Trial, Erp];
        data_temp       = [data_temp; data_subj_small];
    end

    %% group
    disp(['Completing group ' num2str(group)])
    clear Group
    Group(1:length(data_temp)) = j;
    if isrow(Group)
        Group = Group';
    end
    data = [Group, data_temp];
    data_subj = [data_subj; data]; %
    clear data data_temp Group
end

Group      = (data_subj(:,1));
Subject    = (data_subj(:,2));
Trial      = (data_subj(:,4));
Condition  = (data_subj(:,3));
Erp        = (data_subj(:,5));

T = table(Subject, Group, Condition, Trial, Erp);
%saving
if  contains(typefile,'.')
    filename_table = [save_path 'matlab_data_for_export_' name_timewindow typefile];
    writetable(T, filename_table);
    disp(['saved matlab_data_for_export_' name_timewindow typefile ' in ' save_path])
else
    filename_table = [save_path 'matlab_data_for_export_' name_timewindow '.' typefile];
    writetable(T, filename_table);
    disp(['saved matlab_data_for_export_' name_timewindow '.' typefile ' in ' save_path])
end