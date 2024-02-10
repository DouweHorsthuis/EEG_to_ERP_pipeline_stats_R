clear all
home_path    = 'C:\Users\douwe\Desktop\processed\'; %place data is (something like 'C:\data\')
Group_list={'adult_controls', 'cystinosis'};
%if the Eye tracking (ET) files were not saved as PGN add here the path to
%the edf files: 
edf_path = 'C:\Users\douwe\Desktop\DATA\' ;
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'cystinosis' )
        subject_list = { '9182' '9182' '9109'};
    elseif strcmpi(Group_list{gr},'adult_controls')
        subject_list = {'12709' '12091'  '12883'};
    elseif strcmpi(Group_list{gr},'grn')
        subject_list = {'id_1' 'id_2'};
    else
        disp('not possible')
        pause()
    end
    channels_names={'Fcz' 'Fc4' 'Fc3'}; %channels that you want ERP plots for
    plotting_bins=[1:3]; %numbers of the bins you want to plot if 
    colors={'b-' 'm-' 'g-'  };%'k-' 'r-'
    epoch_time = [-50 500];
    load([home_path 'participant_info_' Group_list{gr}]);
    
    participant_info_full=participant_info;
    %load([home_path 'Visual_Gating_participant_info_RT']);


    for s=1:length(subject_list)
        for i=1:height(participant_info_full)
            if strcmpi(participant_info_full.('ID')(i),subject_list{s})
                badchan=  participant_info_full.('Deleted channels')(i);
                Hit_green=  participant_info_full.('hit green ')(i);
               Hit_red=  participant_info_full.('hit red ')(i);
               Hit_all=  participant_info_full.('All Hits')(i);
          
            end
        end
        data_path  = [home_path subject_list{s} '/'];
        EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
        %figures to png
        h1= openfig([data_path subject_list{s} '_deleted_channels.fig']);
        print([data_path subject_list{s} '_deleted_channels.png'], '-dpng' ,'-r300');
        h2= openfig([data_path subject_list{s} '_bridged_channels.fig']);
        print([data_path subject_list{s} '_bridged_channels.png'], '-dpng' ,'-r300');
        %creating erps
        ERP = pop_loaderp( 'filename', [subject_list{s} '.erp'], 'filepath', data_path );

        channels=zeros(1,length(channels_names));
        for i = 1:length(channels_names)
            for ii=1:length(ERP.chanlocs)
                if strcmpi(channels_names(i), ERP.chanlocs(ii).labels)
                    channels(i)=ii;
                end
            end
        end
         for i=1:length(channels_names)
            figure();
            for ii=1:length(plotting_bins)
                plot(ERP.times,ERP.bindata(plotting_bins(i),:,plotting_bins(ii))) %plotting_bins(channel),time,bin
                hold on
                %row=bins columns=channels inside those each row=1subject
            end
            legend(ERP.bindescr{plotting_bins(1)}, ERP.bindescr{plotting_bins(2)} , ERP.bindescr{plotting_bins(3)}) %if you want to plot more/less channels change this
            title(channels_names(i))
            xlim(epoch_time);
            print([data_path subject_list{s} '_' strtrim(ERP.bindescr{i}) '_erp'], '-dpng' ,'-r300');
            close all
        end
        %if the ET file was saved as a PGN then don't run this part 
        edf_path_ind=[edf_path subject_list{s} '\'];
        edf_to_figure(edf_path_ind);
        saveas(gcf,[edf_path_ind subject_list{s} '_ET'])
        print([data_path subject_list{s} '_ET' ], '-dpng' ,'-r300');
        close all

        fig=figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf,'color',[0.85 0.85 0.85])
        %Deleted channels (topoplot if amount is >1)

        %ERPS

        for i=1:length(plotting_bins)
            subplot(5,5,i+10);
            imshow([data_path subject_list{s} '_' strtrim(ERP.bindescr{i}) '_erp.png']);
            title('ERPs')
        end
        %information boxes
        annotation('textbox', [0.1, 0.825, 0.1, 0.1], 'String', [EEG.date; EEG.age; EEG.sex; EEG.Hand; EEG.glasses; EEG.Exp;EEG.Externals;EEG.Light; EEG.Screen; EEG.Cap;])
        annotation('textbox', [0.25, 0.825, 0.1, 0.1], 'String', [EEG.vision_info; EEG.vision; EEG.hearing_info; EEG.hz500; EEG.hz1000; EEG.hz2000; EEG.hz4000]);
        annotation('textbox', [0.25, 0.65, 0.1, 0.1], 'String',  EEG.Medication);
        annotation('textbox', [0.1, 0.6, 0.1, 0.1], 'String', [...
            "Lowpass filter: " + EEG.filter.lowpass_filter_hz(1) + "Hz";...
            "Highpass filter: " + EEG.filter.highpass_filter_hz(1) + "Hz";...
            "Data deleted: " + num2str(EEG.deleteddata_wboundries) + "%";...
            "Bad chan: " + badchan;...
            "Amount bridged chan: " + string(length(EEG.bridged));...
            ]);
        annotation('textbox', [0.10, 0.345, 0.1, 0.1], 'String',EEG.notes)
        annotation('textbox', [0.10, 0.15, 0.1, 0.1], 'String',[...
            "N Hit Green trials " + Hit_green...
            "N Hit Red trials " + Hit_red...
            "N Hit all trials " + Hit_all...
            ])

        %Bridged channels (topoplot if amount is >1)
        subplot(10,10,[5:6 15:16 25:26]);
        if ~isempty(EEG.bridged)
            imshow([data_path subject_list{s} '_bridged_channels.png']);
            title('Bridged channels')
        else
            title('There are NO bridged channels')
        end
        subplot(10,10,[7:10 17:20 27:30]);
        imshow([data_path subject_list{s} '_deleted_channels.png']);
        title('Deleted channels')

        subplot(10,10,[71:75 81:85 91:95]);
        imshow([data_path subject_list{s} '_Bad_ICs_topos.png']);
        title('Bad components')

        subplot(10,10,[75:76 85:86 95:96]);
        imshow([data_path subject_list{s} '_remaining_ICs_topos.png']);
        title('Remaining components')

        subplot(10,10,[77:80 87:90 97:100]);
        imshow([data_path subject_list{s} '_ET.png']);
        title('Eye Tracking')
        

        %Final adjustments for the PDF
        sgtitle(['Quality of ' subject_list{s} 's data while doing the Flanker task']);
        set(gcf, 'PaperSize', [16 10]);
        print(fig,[data_path subject_list{s} '_data_quality'],'-dpdf') % then print it
        print(fig,['D:\cystinosis\Flanker\Quality Check\' subject_list{s} '_data_quality'], '-dpdf');
        close all
    end
end