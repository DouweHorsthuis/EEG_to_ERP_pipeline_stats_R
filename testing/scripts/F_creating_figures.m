%creating figures for the dashboard
%this script needs to be modified for every paradigm
clear variables
close all
eeglab
%% Subject info for each script
subject_list = {'6209' '6239' '8103' '8110' '8110-01' '8113' '8117' '8119' '8121' '8121-01' '8128' '8128-01'}; %all the IDs for the indivual particpants
home_path    = 'C:\Users\dohorsth\Desktop\cued-boss\'; %place data is (something like 'C:\data\')
% info for the ERPs
channels_names={'Oz', 'Fcz'}; %channels that you want ERP plots for
plotting_bins=[1:4];
colors={'b-' 'm-' 'g-' 'r-'};
epoch_time = [-50 800];
% eyetracking
ET='no'; %'yes' or 'no' will create a avg gaze plot
%% first creating one for each subject
for t=1:2
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '\'];
        % EEG = pop_loadset('filename', [subject_list{s} '_epoched.set'], 'filepath', data_path);
        if t==2 %we need to first run other stuff one time
            %% RT figures
            %loading the RTs created in previous script
            RT = readtable([data_path subject_list{s} '_rt.xls']);
            RT_names=RT.Properties.VariableNames;
            RT = table2array(RT);
            quarter_rt=floor(length(RT)/4); %splitting in 4 groups (so we can see if RT is different accros paradigm
            %hits
            figure();
            boxplot([RT(1:quarter_rt,1),...
                RT(quarter_rt+1:quarter_rt*2,1),...
                RT(quarter_rt*2+1:quarter_rt*3,1),...
                RT(quarter_rt*3+1:quarter_rt*4,1)],...
                'Labels',{'1/4' '2/4', '3/4' '4/4'});
            saveas(gcf,[data_path subject_list{s} '_rt_hit_boxpl'])
            close all
            
            %False alarms
            if length(RT(~isnan(RT(:,2))))>0 && length(RT(~isnan(RT(:,3))))>0 && length(RT(~isnan(RT(:,4))))>0
                %plotting all 3 because they all have data
                figure(); boxplot([RT(:,2),RT(:,3),RT(:,4)],'Labels',RT_names(2:4));
                saveas(gcf,[data_path subject_list{s} '_RT_boxpl'])
            elseif length(RT(~isnan(RT(:,2))))>0 && length(RT(~isnan(RT(:,3))))>0
                %plottin only 2 and 3
                figure(); boxplot([RT(:,2), RT(:,3)],'Labels',RT_names(2:3))
            elseif length(RT(~isnan(RT(:,3))))>0 && length(RT(~isnan(RT(:,4))))>0
                %plottin only 3 and 4
                figure();boxplot([RT(:,3),RT(:,4)],'Labels',RT_names(3:4))
            elseif length(RT(~isnan(RT(:,2))))>0 && length(RT(~isnan(RT(:,4))))>0
                %plottin only 2 and 4
                figure();boxplot([RT(:,2),RT(:,4)],'Labels',RT_names([2 4]))
            elseif length(RT(~isnan(RT(:,2))))>0
                %plottin only 2
                figure();boxplot([RT(:,2)],'Labels',RT_names(2))
            elseif length(RT(~isnan(RT(:,3))))>0
                %plottin only 3
                figure();boxplot([RT(:,3)],'Labels',RT_names(3))
            elseif length(RT(~isnan(RT(:,4))))>0
                %plottin only 4
                figure();boxplot([RT(:,4)],'Labels',RT_names(4))
            end
            saveas(gcf,[data_path subject_list{s} '_rt_fa_boxpl'])
            close all
            %% eye tracking
            if strcmpi(ET,'yes')
                edf_to_figure(data_path);
                saveas(gcf,[data_path subject_list{s} '_ET'])
                close all
            end
        end
        %% ERPs
        %first set up channel names conversion
        ERP = pop_loaderp( 'filename', [subject_list{s} '.erp'], 'filepath', data_path );
        
        channels=zeros(1,length(channels_names));
        for i = 1:length(channels_names)
            for ii=1:length(ERP.chanlocs)
                if strcmpi(channels_names(i), ERP.chanlocs(ii).labels)
                    channels(i)=ii;
                end
            end
        end
        for i=1:length(plotting_bins)
            figure();
            for ii=1:length(channels_names)
                plot(ERP.times,ERP.bindata(channels(ii),:,i))
                hold on
                if t==2 %adding the avg to it
                    plot(ERP.times,grand_avg{i, ii})
                    hold on
                end
                avg_erp{i, ii}(s,:)=ERP.bindata(channels(ii),:,i); %creating a group var
                %row=bins columns=channels inside those each row=1subject
            end
            legend([channels_names{1} ' ' subject_list{s}], [channels_names{2} ' ' subject_list{s}], [channels_names{1} ' group avg'], [channels_names{2} ' group avg'] )
            title(ERP.bindescr(i))
            xlim(epoch_time);
            saveas(gcf,[data_path subject_list{s} '_' strtrim(ERP.bindescr{i}) '_erp'])
            close all
        end
        
    end
    for i=1:length(plotting_bins)
        for ii=1:length(channels_names)
            grand_avg{i,ii}=mean(avg_erp{i, ii});
        end
    end
end