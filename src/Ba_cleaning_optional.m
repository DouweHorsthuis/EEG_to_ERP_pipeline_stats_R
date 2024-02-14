% This is optional, because this will check how high/low are the ideal
% settings for your data set to clean as much as needed but also to not
% delete too much data. You can opt for the standard settings. This takes a
% while to run. 
% Created by Douwe Horsthuis last update 2/14/2024
% ------------------------------------------------
clear variables
eeglab
% This defines the set of subjects
subject_list = {'Participant_1_ID' 'Participant_2_ID'};
home_path    = 'C:\Users\whereisyourdata\'; %place data is (something like 'C:\data\')
%% Settings for the script 
Burst_criteria=0.70:0.05:0.80;%start point, step size, end point
Channel_criteria=20:5:50;%start point, step size, end point
chan_threshold=64*0.10;% 64*0.10 means that if more than 10% of the channels are deleted, the participant is considered bad
cont_data_threshold=30;% the number here is the max percentage of data that can be deleted before a participant is considered bad 
%% make sure that these are the same as your real script
downsample_to=256; % what is the sample rate you want to downsample to
lowpass_filter_hz=45; %45hz filter
highpass_filter_hz=0.1; %1hz filter

%% quick loop so we only have to do this 1x at the start
for s=1:length(subject_list)
    fprintf('\n\n****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ***                                                                                                             *** Processing subject %s this is participant %s 2nd part ******\n\n ', subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s));
    data_path  = [home_path subject_list{s} '\\'];
        EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
        
    EEG = pop_resample( EEG, downsample_to);
    EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_hz);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_hz);
    EEG=pop_chanedit(EEG, 'lookup',[fileparts(which('eeglab')) '\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp'],'rplurchanloc',[1]); %make sure you put here the location of this file for your computer
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
    %saving as _info, because in the real script we will overwrite this
end
%% the real work
for s=1:length(subject_list)
    quality(s,:)=str2double(subject_list{s});
end

for s=1:length(subject_list)
    fprintf('\n\n****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ****** Processing subject %s this is participant %s 1st part ***                                                                                                             *** Processing subject %s this is participant %s 2nd part ******\n\n ', subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s),subject_list{s},num2str(s));
    data_path  = [home_path subject_list{s} '\\'];
    st=2; fnsh=4;
    for chn_crit=Burst_criteria
        for crit=Channel_criteria
            EEG = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);
            EEG = pop_select( EEG, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
            old_samples=EEG.pnts;
            EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',chn_crit,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',crit,'WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
            del_chan=0;
            if EEG.nbchan<64 %one channel at least deleted
                for i= 1:length(EEG.chaninfo.removedchans)
                    if strcmpi(EEG.chaninfo.removedchans(i).type,'EEG')
                        del_chan=del_chan+1;
                    end
                end
            end
            quality(s,st:fnsh)= [100-EEG.pnts/old_samples*100, round(EEG.xmax), del_chan ];
            st=st+3; fnsh=fnsh+3;
        end
    end
end
colNames                   = {'ID','%data deleted @20 - 0.7', 'seconds of data @20- 0.7', 'deleted chan @20- 0.7','%data deleted @25-0.7', 'seconds of data @25-0.7', 'deleted chan @25-0.7','%data deleted @30-0.7', 'seconds of data @30-0.7', 'deleted chan @30-0.7','%data deleted @35-0.7', 'seconds of data @35-0.7', 'deleted chan @35-0.7','%data deleted 40-0.7', 'seconds of data @40-0.7', 'deleted chan @40-0.7','%data deleted @45-0.7', 'seconds of data @45-0.7', 'deleted chan @45-0.7','%data deleted @50-0.7', 'seconds of data @50-0.7', 'deleted chan @50-0.7', '%data deleted @20 - 0.75', 'seconds of data @20- 0.75', 'deleted chan @20- 0.75','%data deleted @25-0.75', 'seconds of data @25-0.75', 'deleted chan @25-0.75'  ,'%data deleted @30-0.75', 'seconds of data @30-0.75', 'deleted chan @30-0.75','%data deleted @35-0.75', 'seconds of data @35-0.75', 'deleted chan @35-0.75'  ,'%data deleted 40-0.75', 'seconds of data @40-0.75', 'deleted chan @40-0.75','%data deleted @45-0.75', 'seconds of data @45-0.75', 'deleted chan @45-0.75' ,'%data deleted @50-0.75', 'seconds of data @50-0.75', 'deleted chan @50-0.75','%data deleted @20 - 0.8', 'seconds of data @20- 0.8', 'deleted chan @20- 0.8' ,'%data deleted @25-0.8', 'seconds of data @25-0.8', 'deleted chan @25-0.8' ,'%data deleted @30-0.8', 'seconds of data @30-0.8', 'deleted chan @30-0.8' ,'%data deleted @35-0.8', 'seconds of data @35-0.8', 'deleted chan @35-0.8' ,'%data deleted 40-0.8', 'seconds of data @40-0.8', 'deleted chan @40-0.8','%data deleted @45-0.8', 'seconds of data @45-0.8', 'deleted chan @45-0.8'  ,'%data deleted @50-0.8', 'seconds of data @50-0.8', 'deleted chan @50-0.8'}; %adding names for columns [ERP.bindescr] adds all the name of the bins
threshold_cleaning = array2table( quality,'VariableNames',colNames); %creating table with column names
save([home_path 'Threshold_cleaning_information'], 'threshold_cleaning', 'quality');
%% building figure
%Bad participants (>30% data deleted, >10 chn deleted)
bad_participant=[];
for i=2:3:size(quality,2)
    too_much_cont_data_del=0;too_much_chan_del=0;bad_part=0;
    for ii=1:size(quality,1)
        if quality(ii,i)>cont_data_threshold
            too_much_cont_data_del=too_much_cont_data_del+1;
        end
        if quality(ii,i+2)>chan_threshold %>7 is more or less 10% channels deleted
            too_much_chan_del=too_much_chan_del+1;
        end
        if quality(ii,i)>30 && quality(ii,i+2)>7
            bad_participant=[bad_participant;quality(ii,1), colNames(i)];
            bad_part=bad_part+1;
        end
    end
    del_data(i)=too_much_cont_data_del;del_data(i+1)=too_much_chan_del;del_data(i+2)= bad_part;
end

%burst vs channel
figure('units','normalized','outerposition',[0 0 1 1])
fig2=tiledlayout(3,5);
first=2; sec=5; thrd=8;fourth=11; fifth=14; sixth=17; seventh=20;
n_tile=1;
for i=0.70:0.05:0.80 % this is the same as the channel criteria
    nexttile([n_tile n_tile+2])
    boxplot(quality(:,[first,sec,thrd,fourth,fifth, sixth,seventh]))
    ylim([0 101])
    title(['Channel crit @ ' num2str(i)])
    xticklabels({'20', '25','30','35','40','45','50'})
    xlabel('Burst criteria')
    ylabel('% deleted data')
     n_tile+5;
    nexttile
    b=bar(del_data(1,first:3:seventh+1));
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = string(b(1).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xticklabels({'20', '25','30','35','40','45','50'})
    xlabel('Burst criteria')
    ylabel('N participants with >30% data deleted')
    ylim([0 max(ytips1)*1.2]) %giving some space for the biggest number to fit
    nexttile
    b=bar(del_data(1,first+1:3:seventh+2));
    xtips1 = b(1).XEndPoints;
    ytips1 = b(1).YEndPoints;
    labels1 = string(b(1).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    xticklabels({'20', '25','30','35','40','45','50'})
    xlabel('Burst criteria')
    ylabel('N participants with >10% chan deleted')
    first=first+21; sec=sec+21; thrd=thrd+21; fourth=fourth+21; fifth=fifth+21; sixth=sixth+21; seventh=seventh+21;
    ylim([0 max(ytips1)*1.2]) %giving some space for the biggest number to fit
end
title(fig2,'Deleted continues data VS Burstcriteria')
print([home_path 'cleaning - Burstcriteria'], '-dpng' ,'-r300');
close all

%channels
figure('units','normalized','outerposition',[0 0 1 1])
fig3=tiledlayout(4,4);
first=4; second=25; third=46;
for i = 20:5:50 % 7 thresholds
    nexttile
    boxplot(quality(:,[first,second,third]))
    %ylim([0 101])
    title(['BurstCriterion @ ' num2str(i)])
    xticklabels({'0.70', '0.75','0.80'})
    xlabel('Channel criteria')
    ylabel('N deleted channels')
  nexttile
  y=[del_data(1,first-2:first);  del_data(1,first+19:first+21); del_data(1,first+40:first+42)];
  b=bar(y); %need to plot 3x3 bars with diff color
  for ii=1:3 
  xtips1 = b(ii).XEndPoints;
    ytips1 = b(ii).YEndPoints;
    labels1 = string(b(ii).YData);
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
  end
    xticklabels({'0.7', '0.75','0.8'})
    ylim([0 max(max(y))*1.2]) %giving some space for the biggest number to fit
    first=first+3; second=second+3; third=third+3;
    
end
legend('>30% data deleted', '>10% chan deleted','Both too much')
leg = legend('Orientation', 'Horizontal');
leg.Layout.Tile = 16;
title(fig3,'Deleted channels vs channel threshold')
print([home_path 'cleaning - Channels'], '-dpng' ,'-r300');
close all



