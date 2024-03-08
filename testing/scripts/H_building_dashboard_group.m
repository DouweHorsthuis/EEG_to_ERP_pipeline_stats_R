% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 2/14/2024
% This script creates dashboards
% it wil first create one for each participant of a group
% it wil then proceed to create one on a group level
clear all
home_path    = 'C:\Users\douwe\Desktop\processed_new\'; %place data is (something like 'C:\data\')
save_path_gr =  'C:\Users\douwe\Desktop\processed_new\'; %where to save the group level figure
edf_path = 'C:\Users\douwe\Desktop\DATA\'; %home path to where de EDF files are
Group_list={'controls' 'cystinosis'};
task_name = 'SWAT';
channels_names={'Fcz' 'Cz'}; %channels that you want ERP plots for
epoch_time = [-50 500];
Plot_bins={'All'}; %either names from ERP.bindescr or 'All'
RT_yn = 'Yes'; %'Yes' 'No' - only if RT exist you can plot this
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'cystinosis' )
        subject_list = { '9182' '9182' '9109'};
    elseif strcmpi(Group_list{gr},'controls')
        subject_list = {'12709' '12091'  '12883'};
    elseif strcmpi(Group_list{gr},'grn')
        subject_list = {'id_1' 'id_2'};
    else
        disp('not possible')
        pause()
    end
    GRP_ERP = pop_loaderp( 'filename', [Group_list{gr} '.erp'], 'filepath', home_path );
    %loading the information about all the people for one group
    load([home_path 'participant_info_' Group_list{gr}]);
    if strcmpi(RT_yn, 'yes')
        RT_cell= readcell([home_path 'RTs.xlsx'])
    end
    participant_info_full=participant_info;
    for s=1:length(subject_list)
        for i=1:height(participant_info_full)
            if strcmpi(participant_info_full.('ID')(i),subject_list{s})
                badchan=  participant_info_full.('Deleted channels')(i);
            end
        end
        %adding bins to a usuable table
        for j = 1:length(participant_info_full.Properties.VariableNames)%going passed all the columns
            if  strcmpi(Plot_bins, 'All') %if input == all
                for i = 1:ERP.nbin %then we need to loop throug all
                    if strcmpi(strtrim(participant_info_full.Properties.VariableNames{j}), strtrim(ERP.bindescr(i)))
                        for sub=1:length(subject_list)
                            if strcmpi(participant_info_full{sub,1}, string(subject_list{s}))
                                bin(i)=participant_info_full.(j)(sub);
                            end
                        end
                    end
                end
            else
                for i = 1:length(Plot_bins) % to see if they match any of the bins we want to plot
                    if strcmpi(strtrim(participant_info_full.Properties.VariableNames{j}), strtrim(Plot_bins(i)))
                        for sub=1:length(subject_list)
                            if strcmpi(participant_info_full{sub,1}, string(subject_list{s}))
                                bin(i)=participant_info_full.(j)(sub);
                            end
                        end
                    end
                end
            end
        end
        data_path  = [home_path subject_list{s} '/'];
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
        %figures to png
        h1= openfig([data_path subject_list{s} '_deleted_channels.fig']);
        print([data_path subject_list{s} '_deleted_channels.png'], '-dpng' ,'-r300');
        h2= openfig([data_path subject_list{s} '_bridged_channels.fig']);
        print([data_path subject_list{s} '_bridged_channels.png'], '-dpng' ,'-r300');
        h3= openfig([data_path subject_list{s} '_ET.fig']);
        print([data_path subject_list{s} '_ET.png'], '-dpng' ,'-r300');
        %creating erps
        ERP = pop_loaderp( 'filename', [subject_list{s} '.erp'], 'filepath', data_path );
        %using the channel names (input) to find the index number of the channel
        channels=zeros(1,length(channels_names)); %pre-allocating
        for i = 1:length(channels_names) %for all the channel names from input
            for ii=1:length(ERP.chanlocs) %check all the existing channel locations for a match
                if strcmpi(channels_names(i), ERP.chanlocs(ii).labels) %if match is found
                    channels(i)=ii; %use that number as the channel number
                end
            end
        end
        %we now figure out the bins
        bin_N=[]; %empty it, so it won't be confused
        if  strcmpi(Plot_bins, 'All') %if input == all
            bin_N=1:ERP.nbin; %do a copy
        else
            for b=1:length(Plot_bins) %check for the amount of inputs
                for i=1:length(ERP.bindescr) %if they are identical to the ERP bin discription
                    if strcmpi(strtrim(Plot_bins{b}),strtrim(ERP.bindescr{i})) %if match is found
                        bin_N(b)= i; %us that bin number
                    end
                end
            end
        end
        for i=1:length(channels_names)
            figure();
            clear legendInfo
            for iii=1:2 %once do the thing for the individual once for the grand mean
                for ii=1:length(bin_N)
                    if iii==1
                        plot(ERP.times,ERP.bindata(channels(i),:,bin_N(ii))) %plotting_bins(channel),time,bin
                        legendInfo{ii} = ERP.bindescr{bin_N(ii)};
                        hold on
                    else
                        plot(GRP_ERP.times,GRP_ERP.bindata(channels(i),:,bin_N(ii))) %plotting_bins(channel),time,bin
                        legendInfo{ii+length(bin_N)} = [ERP.bindescr{bin_N(ii)} , ' grand mean'];
                        hold on
                    end
                    %row=bins columns=channels inside those each row=1subject
                end
            end
            legend(legendInfo)
            title(channels_names(i)) %channels name as title
            xlim(epoch_time); %shortens the plot to only contain epoch time
            print([data_path subject_list{s} '_' strtrim(channels_names{i}) '_erp'], '-dpng' ,'-r300');
            close all
        end
        %RTs
        RT_sub=[];
        for sub=1:size(RT_cell,1) %check for the whole thing
            if strcmpi(RT_cell{sub,1},subject_list{s}) %if the row has the right subject
                RT_sub=[RT_sub;RT_cell(sub,3),RT_cell(sub,4)]; %bin,RT
            end
        end
        boxchart(cell2mat(RT_sub(:,2)),'GroupByColor',categorical(RT_sub(:,1)));
        legend()
        title("Reaction time") %channels name as title
        ylabel('RT in ms')
        xlabel('Different Bins')
        print([data_path subject_list{s} '_RTs'], '-dpng' ,'-r300');
        close all




        %% start of the plotting
        fig=figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf,'color',[0.85 0.85 0.85])


        %ERPS
        if size(channels_names,2) > 5
            error("You have too many Channels, 5 is the max for plotting")
        end
        for i=1:length(channels_names)
            subplot(10,10,[70+i+(i-1):70+i+i 80+i+(i-1):80+i+i 90+i+(i-1):90+i+i]);%deleted
            imshow([data_path subject_list{s} '_' strtrim(channels_names{i}) '_erp.png']);
            title('ERPs')
        end


        %text loops
        bin_text = []; %clearing it

        for i=1:size(bin,2) %for every bin
            bin_text{i} =   bin(i)  + " trials remaining of type " + strtrim(string(strtrim(ERP.bindescr{i}))); %write down "amount + trials remaining of type + name of the bin"
        end

        bin_text=["Total remaining trials", bin_text]; %adding a sort of title

        %information boxes being created and printed.
        annotation('textbox', [0.10, 0.825, 0.1, 0.1], 'String', [EEG.date; EEG.age; EEG.sex; EEG.Hand; EEG.glasses; EEG.Exp;EEG.Externals;EEG.Light; EEG.Screen; EEG.Cap;])
        annotation('textbox', [0.25, 0.825, 0.1, 0.1], 'String', [EEG.vision_info; EEG.vision; EEG.hearing_info; EEG.hz500; EEG.hz1000; EEG.hz2000; EEG.hz4000]);
        annotation('textbox', [0.25, 0.65, 0.1, 0.1], 'String',  EEG.Medication);
        annotation('textbox', [0.10, 0.6, 0.1, 0.1], 'String', [...
            "Lowpass filter: " + EEG.filter.lowpass_filter_hz(1) + "Hz";...
            "Highpass filter: " + EEG.filter.highpass_filter_hz(1) + "Hz";...
            "Data deleted: " + num2str(EEG.deleteddata_wboundries) + "%";...
            "Bad chan: " + badchan;...
            "Amount bridged chan: " + string(length(EEG.bridged));...
            ]);
        annotation('textbox', [0.10, 0.48, 0.1, 0.1], 'String',bin_text)
        annotation('textbox', [0.10, (0.48 - (0.01 + length(bin_text)*0.01)*2), 0.1, 0.1], 'String',EEG.notes)


        %Bridged channels (topoplot if amount is >1)
        subplot(10,10,[5:6 15:16 25:26]);
        if ~isempty(EEG.bridged)
            imshow([data_path subject_list{s} '_bridged_channels.png']);
            title('Bridged channels')
        else
            title('There are NO bridged channels')
        end

        subplot(10,10,[7:8 17:18 27:28]);
        imshow([data_path subject_list{s} '_deleted_channels.png']);
        title('Deleted channels')

        subplot(10,10,[9:10 19:20 29:30]);%deleted
        imshow([data_path subject_list{s} '_ET.png']);
        title('Eye Tracking')

        subplot(10,10,[35:36 45:46 55:56])
        imshow([data_path subject_list{s} '_RTs.png']);
        title('Reaction time')

        subplot(10,10,[37:38 47:48 57:58]);
        imshow([data_path subject_list{s} '_Bad_ICs_topos.png']);
        title('Bad components')

        subplot(10,10,[39:40 49:50 59:60]);
        imshow([data_path subject_list{s} '_remaining_ICs_topos.png']);
        title('Remaining components')





        %Final adjustments for the PDF
        sgtitle(['Quality of ' subject_list{s} 's data while doing the ' task_name ' task']);
        set(gcf, 'PaperSize', [16 10]);
        print(fig,[data_path subject_list{s} '_data_quality'],'-dpdf') % then print it
        close all
    end %end of subject level
    %% Start of group level plotting
    %eye tracking at a group level
    %input needs to be: edf_path=loctation with the participant folders (their names need to match the subject IDs,
    %subject_list = list with all the subject IDs
    edf_to_figure_group(edf_path,subject_list);
    saveas(gcf,[home_path Group_list{gr} '_ET'])
    print([home_path Group_list{gr} '_ET' ], '-dpng' ,'-r300');
    close all
    %ERP at group level needs to exist for this , this is identical to the
    %individual level, but on the group erp
    ERP = pop_loaderp( 'filename', [Group_list{gr} '.erp'], 'filepath', home_path );
    for i=1:length(channels_names)
        figure();
        for ii=1:length(bin_N)
            % plot(ERP.times,ERP.bindata(plotting_bins(i),:,plotting_bins(ii))) %plotting_bins(channel),time,bin
            plot(ERP.times,ERP.bindata(channels(i),:,bin_N(ii))) %plotting_bins(channel),time,bin
            hold on
            %row=bins columns=channels inside those each row=1subject
            legendInfo{ii+length(bin_N)} = [ERP.bindescr{bin_N(ii)} , ' grand mean'];
        end
        legend(legendInfo)
        title(channels_names(i)) %channels name as title
        xlim(epoch_time); %shortens the plot to only contain epoch time
        print([home_path Group_list{gr} '_' strtrim(channels_names{i}) '_erp'], '-dpng' ,'-r300');
        close all
    end
    RT_gr=[];
    for sub=1:size(RT_cell,1) %check for the whole thing
        if strcmpi(RT_cell{sub,2},Group_list{gr}) %if the row has the right group
            RT_gr=[RT_gr;RT_cell(sub,3),RT_cell(sub,4)]; %bin,RT
        end
    end
    boxchart(cell2mat(RT_gr(:,2)),'GroupByColor',categorical(RT_gr(:,1)));
    legend()
    title("Reaction time") %channels name as title
    ylabel('RT in ms')
    xlabel('Different Bins')
    print([home_path Group_list{gr} '_RTs'], '-dpng' ,'-r300');
    close all


    %starting the group dashboard
    fig=figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color',[0.85 0.85 0.85])
    full_group_name = strrep(Group_list{gr},'_',' ');
    subplot(10,10,[4:6 14:16 24:26 34:36]);
    imshow([home_path Group_list{gr} '_ET.png']);
    title('Eye Tracking')

    %RT without title since it overlaps
    subplot(10,10,[21:23 31:33 41:43 51:53]);
    imshow([home_path Group_list{gr} '_RTs.png']);


    %If you want more than 3 ERPs than you need to change here the size
    %of the subplots.
    x=[0,3,6];
    for i=1:length(channels_names)
        subplot(10,10,[61+x(i):63+x(i) 71+x(i):73+x(i) 81+x(i):83+x(i) 91+x(i):93+x(i)]);%
        imshow([home_path Group_list{gr} '_' strtrim(channels_names{i}) '_erp.png']);
        title('ERPs')
    end

    subplot(10,10,[7:10 17:20 27:30 37:40]);
    imshow([home_path Group_list{gr} '_deleted_channels.png']);
    title('Deleted channels')
    %looking for some info to write down
    main_folder=dir(home_path);
    for l=1:length(main_folder)
        %looking for the group ERP date
        if strcmpi([Group_list{gr} '.erp'],main_folder(l).name)
            create_date=['The grand average ' full_group_name '.erp was created on ' main_folder(l).date];
        end
    end

    group_size= ['There are ' num2str(length(ERP.workfiles)) ' participants in this group'];
    date_dashboard = "This group dashboard was created on " + datestr(datetime("today"));
    %Here you can add more info per group
    annotation('textbox', [0.1, 0.800, 0.1, 0.1], 'String', [date_dashboard; ...
        create_date; ...
        group_size;...
        "Lowpass filter: " + EEG.filter.lowpass_filter_hz(1) + "Hz";...
        "Highpass filter: " + EEG.filter.highpass_filter_hz(1) + "Hz";...
        "During the experiment (based on last participant):";...
        EEG.Light;...
        EEG.Screen])


    %Final adjustments for the PDF
    sgtitle(['Quality of the ' full_group_name ' group data while doing the ' task_name ' task']);
    set(gcf, 'PaperSize', [16 10]);
    print(fig,[save_path_gr Group_list{gr} '_data_quality'],'-dpdf') % then print it

    close all
    %info needed for the last plots
    sizes_groups(gr)=length(ERP.workfiles);
end
%% final - comparing groups

ERP = pop_loaderp( 'filename', 'Groups_combined.erp', 'filepath', home_path );

%we now figure out the bins
bin_N=[]; %empty it, so it won't be confused
if  strcmpi(Plot_bins, 'All') %if input == all
    bin_N=1:ERP.nbin; %do a copy
else
    for b=1:length(Plot_bins) %check for the amount of inputs
        for i=1:length(ERP.bindescr) %if they are identical to the ERP bin discription
            if strcmpi(strtrim(Plot_bins{b}),strtrim(ERP.bindescr{i})) %if match is found
                bin_N(b)= i; %us that bin number
            end
        end
    end
end
%Plotting again and figuring bins out because there are double now (each
%group has its own set of bins
clear legendInfo
for i=1:length(channels_names)
    figure();
    for ii=1:length(bin_N)
        % plot(ERP.times,ERP.bindata(plotting_bins(i),:,plotting_bins(ii))) %plotting_bins(channel),time,bin
        plot(ERP.times,ERP.bindata(channels(i),:,bin_N(ii))) %plotting_bins(channel),time,bin
        hold on
        %row=bins columns=channels inside those each row=1subject
        legendInfo{ii} = [ERP.bindescr{bin_N(ii)}];
    end
    legend(legendInfo)
    title(channels_names(i)) %channels name as title
    xlim(epoch_time); %shortens the plot to only contain epoch time
    print([home_path 'All_' strtrim(channels_names{i}) '_erp'], '-dpng' ,'-r300');
    close all
end

boxchart(cell2mat(RT_cell(:,4)),'GroupByColor',categorical(RT_cell(:,2)).*categorical(RT_cell(:,3)));
legend()
title("Reaction time") %channels name as title
ylabel('RT in ms')
xlabel('Different Bins')
print([home_path 'All_RTs'], '-dpng' ,'-r300');
close all


%% starting the group dashboard
fig=figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[0.85 0.85 0.85])

    for i=1:length(channels_names)
        subplot(10,10,[61+x(i):63+x(i) 71+x(i):73+x(i) 81+x(i):83+x(i) 91+x(i):93+x(i)]);%
        imshow([home_path Group_list{gr} '_' strtrim(channels_names{i}) '_erp.png']);
        title('ERPs')
    end


for gr=1:length(Group_list)
if gr==1
    x=0;
else 
    x=3;
end
subplot(10,10,[5+x:7+x 15+x:17+x 25+x:27+x ]);
imshow([home_path Group_list{gr} '_ET.png']);
end



%RT without title since it overlaps
subplot(10,10,[21:23 31:33 41:43 51:53]);
imshow([home_path 'All_RTs.png']);


%If you want more than 3 ERPs than you need to change here the size
%of the subplots.
x=[0,3,6];
for i=1:length(channels_names)
    subplot(10,10,[61+x(i):63+x(i) 71+x(i):73+x(i) 81+x(i):83+x(i) 91+x(i):93+x(i)]);%
    imshow([home_path 'All_' strtrim(channels_names{i}) '_erp.png']);
    title('ERPs')
end


%looking for some info to write down
main_folder=dir(home_path);
for l=1:length(main_folder)
    %looking for the group ERP date
    if strcmpi([Group_list{gr} '.erp'],main_folder(l).name)
        create_date=['The ' ERP.filename ' was created on ' main_folder(l).date];
    end
end
group_size= ['There are ' num2str(length(Group_list)) ' groups with ' num2str(sizes_groups)  ' participants per group' ];
date_dashboard = "This dashboard was created on " + datestr(datetime("today"));
%Here you can add more info per group
annotation('textbox', [0.1, 0.800, 0.1, 0.1], 'String', [date_dashboard; ...
    create_date; ...
    group_size;...
    "Lowpass filter: " + EEG.filter.lowpass_filter_hz(1) + "Hz";...
    "Highpass filter: " + EEG.filter.highpass_filter_hz(1) + "Hz";...
    "During the experiment (based on last participant):";...
    EEG.Light;...
    EEG.Screen])

%Final adjustments for the PDF
sgtitle(['Quality of the the combined groups while doing the ' task_name ' task']);
set(gcf, 'PaperSize', [16 10]);
print(fig,[save_path_gr Group_list{gr} '_data_quality'],'-dpdf') % then print it
close all