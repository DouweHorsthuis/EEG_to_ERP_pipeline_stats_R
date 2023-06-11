clear all
home_path    = 'D:\whereisthebinlisttextfile\'; %place data is (something like 'C:\data\')
save_path    = 'D:\folderwhereallthepdfsgo\';
Group_list={'gr1' 'gr2' 'grn'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'gr1')
        subject_list = {'id_1' 'id_2'};
    elseif strcmpi(Group_list{gr},'gr2')
        subject_list = {'id_1' 'id_2'};
    elseif strcmpi(Group_list{gr},'grn')
        subject_list = {'id_1' 'id_2'};
    else
        disp('not possible')
        pause()
    end
    channels_names={'channelname1', 'channelname1', 'channelname3' }; %channels that you want ERP plots for e.g. 'O2' 'Oz', 'O1'
    plotting_bins=[firstbin:lastbin]; %which bins do you want to plot e.g. [1:5]
    Namebin1 = 'namebin1' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'b145'
    Namebin2 = 'namebin2' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'b145'
    Namebin3 = 'namebin3' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'b145'
    Namebin4 = 'namebin4' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'b145'
    Namebin5 = 'namebin5' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'b145'
    Namebin6 = 'namebin6' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'hit '
    Namebin7 = 'namebin7' ;% its the name that you gave to it in the binlist between single quotationmakes eg: 'miss'
    colors={'b-' 'm-' 'g-' 'r-' 'k-'}; %matlab colors for your erps; amount of colors need to match amount of bins; -is full line --dashed :dotted etc.
    epoch_time = [startepoch endepoch]; %length of plotted epoch in MS e.g. [-50 400]
    load([home_path 'participant_info_' Group_list{gr}]);
    participant_info_full=participant_info;



    for s=1:length(subject_list)
        for i=1:height(participant_info_full)
            if strcmpi(participant_info_full.('ID')(i),subject_list{s})
                badchan=  participant_info_full.('Deleted channels')(i);
                Bin1=  participant_info_full.(Namebin1)(i);
                Bin2=  participant_info_full.(Namebin2)(i);
                Bin3=  participant_info_full.(Namebin3)(i);
                Bin4=  participant_info_full.(Namebin4)(i);
                Bin5=  participant_info_full.(Namebin5)(i);
                hit=   participant_info_full.(Namebin6)(i);
                miss=  participant_info_full.(Namebin7)(i);
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
        for i=1:length(plotting_bins)
            figure();
            for ii=1:length(channels_names)
                plot(ERP.times,ERP.bindata(channels(ii),:,i))
                hold on
                %row=bins columns=channels inside those each row=1subject
            end
            legend([channels_names{1} ' ' subject_list{s}], [channels_names{2} ' ' subject_list{s}], [channels_names{1} ' group avg'], [channels_names{2} ' group avg'] )
            title(ERP.bindescr(i))
            xlim(epoch_time);
            print([data_path subject_list{s} '_' strtrim(ERP.bindescr{i}) '_erp'], '-dpng' ,'-r300');
            close all
        end

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
        annotation('textbox', [0.25, 0.6, 0.1, 0.1], 'String', [...
            "Lowpass filter: " + EEG.filter.lowpass_filter_hz(1) + "Hz";...
            "Highpass filter: " + EEG.filter.highpass_filter_hz(1) + "Hz";...
            "Data deleted: " + num2str(EEG.deleteddata_wboundries) + "%";...
            "Bad chan: " + badchan;...
            "Amount bridged chan: " + string(length(EEG.bridged));...
            ]);
        annotation('textbox', [0.10, 0.30, 0.1, 0.1], 'String',EEG.notes)
        annotation('textbox', [0.40, 0.20, 0.1, 0.1], 'String',[...
            "Amount of hits " + Bin5...
            "Amount of misses " + Bin7...
            "N 145 trials " + Bin1...
            "N 245 trials " + Bin2...
            "N 495 trials " + Bin3...
            "N 995 trials " + Bin4...
            "N 2495 trials " + Bin5...
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

        subplot(10,10,[76:80 86:90 96:100]);
        imshow([data_path subject_list{s} '_remaining_ICs_topos.png']);
        title('Remaining components')



        %Final adjustments for the PDF
        sgtitle(['Quality of ' subject_list{s} 's data while doing visual gating']);
        set(gcf, 'PaperSize', [16 10]);
        print(fig,[data_path subject_list{s} '_data_quality'],'-dpdf') % then print it
        print(fig,[save_path subject_list{s} '_data_quality'], '-dpdf');
        close all
    end
end