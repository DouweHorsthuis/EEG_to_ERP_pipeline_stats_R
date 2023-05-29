home_path    = 'E:\Processed\Visual Adaptation\'; %place data is (something like 'C:\data\')
subject_list = {'9102' '9155' '6167' '6169' '6179' '6201' '6209' '6237' '6238' '6239' '6285' '6287' '6288' '6292' '8103' '8103-01' '8110' '8110-01' '8113' '8114' '8114-01' '8117' '8119' '8121' '8121-01'  '8128-01' '8129' '8136' '8145' '8148' '8150' '8157' '8158' '8159' '8161' '8161-01' '8161-02' '8169' '8176' '8176-01' '8177' '8187' '8187-01' '8187-02' '8190' '8261' '8261-01' '8608' '9109' '9109-01' '9119' '9146' '9150' '9176' '9179' '9179-01' '9180' '9182' '9182-01' '9183' '9183-01' '9189' '9193' '10056' '10066' '10085' '10135' '10214' '10260' '10281' '10373' '10400' '10400-01' '10463' '10486' '10486' '10553' '10555' '10567' '10583' '10641' '10769' '10780' '10853' '10862' '10912' '10935' '10951' '10956' '12011' '12067' '12090' '12124' '12156' '12338' '12341' '12351' '12392' '12429' '12434' '12437' '12542' '12543' '12682' '12686' '12709' '12716' '12737' '12762' '12812' '12824' '12840' '12883' '12889'}; %all the IDs for the indivual particpants
channels_names={'O2' 'Oz', 'O1'}; %channels that you want ERP plots for
plotting_bins=[1:5];
colors={'b-' 'm-' 'g-' 'r-' 'k-'};
epoch_time = [-50 400];
load([home_path 'Visual_Gating_participant_info']);
participant_info_full=participant_info;
load([home_path 'Visual_Gating_participant_info_RT']);

%i messed up teh figures of '8128'
for s=1:length(subject_list)
    for i=1:height(participant_info_full)
        if strcmpi(participant_info_full.('ID')(2),subject_list{s})
            badchan=  participant_info.('Deleted channels')(i);
            b145=  participant_info_full.('b145')(i);
            b245=  participant_info_full.('b245')(i);
            b495=  participant_info_full.('b495')(i);
            b995=  participant_info_full.('b995')(i);
            b2495=  participant_info_full.('b2495 ')(i);
            hit= participant_info.('hit ')(i);
            miss= participant_info.('miss')(i);
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
    annotation('textbox', [0.40, 0.30, 0.1, 0.1], 'String',EEG.notes)
    annotation('textbox', [0.40, 0.20, 0.1, 0.1], 'String',[...
        "Amount of hits " + hit...
        "Amount of misses " + miss...
        "N 145 trials " + b145...
        "N 245 trials " + b245...
        "N 495 trials " + b495...
        "N 995 trials " + b995...
        "N 2495 trials " + b2495...
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
    close all
end