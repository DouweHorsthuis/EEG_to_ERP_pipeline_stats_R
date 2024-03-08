clear variables
eeglab
%% Input for the grandmeans
Plot_chans={'Fpz' 'Cz' 'Oz'}; %either channel names e.g. {'fpz' 'F1'} or {'All'}
Plot_bins={'All Hits'}; %either names from ERP.bindescr or 'All'
Plot_binsgr={};
epoch_time_x = [-50 300]; %time in ms e.g. [-50 100]
time_points_x = [-25 0:100:300]; %Time point for the plot in ms -> individual times eg. [-50 10 12 200 322] steps [ 0:50:300] combo [-50 0:100:300]
amplitude_y = [-4.0 10.0]; %[min_y max_y]
amplitude_points_x = [-3 0:2.5:10]; %Amplitude on y-axis similar to time_point_x
plot_tiles = [2 2]; %tiles in the end figures [horizontal_figs vertical_figs] 

home_path    = 'C:\Users\douwe\Desktop\processed_new\'; %place data is (something like 'C:\data\')
%needs no input
GRERP=[];% need to be cleared like this for the avg erps to be kept somewhere
Plot_binsgr={};%needs to be empty
%% Subject info for each script
Group_list={'cystinosis' 'Controls'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'Controls')
        subject_list = {'12091' '12709' '12883'};
    elseif strcmpi(Group_list{gr},'cystinosis')
        subject_list = {'9109' '9182' '9183'};
    elseif strcmpi(Group_list{gr},'grn')
        subject_list = {'id_1' 'id_2'};
    else
        disp('not possible')
        pause()
    end

    ALLERP=[];% need to be cleared like this otherwise all ERPs are joined together of different groups

    for s=1:length(subject_list)
        data_path  = [home_path subject_list{s} '/'];
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        ERP = pop_loaderp( 'filename', [subject_list{s} '.erp'], 'filepath', data_path );
        ALLERP = [ALLERP,ERP];
        %% For plotting
        % we now figure out which channels to plot
        if  strcmpi(Plot_chans, 'All')
            plot_chan_num=1:64; %if all then simply 1:64
        else
            %changing the names of the channels into the right numbers
            plot_chan_num = zeros(length(Plot_chans),1);
            for chan=1:length(Plot_chans) %for each inputted channel we loop
                for plt=1:ERP.nchan %across all channels that exist in the ERP set
                    if strcmpi(Plot_chans{chan},ERP.chanlocs(plt).labels)
                        plot_chan_num(chan) = ERP.chanlocs(plt).urchan; %finds locations etc
                    end
                end
            end
            if length(Plot_chans) ~= length(nonzeros(plot_chan_num))
                error('Not all your input channels can be found in your data')
            end
            %transpose
            plot_chan_num=plot_chan_num';
        end
        %we now figure out the bins
        bin=[];
        if  strcmpi(Plot_bins, 'All')
            Bin=1:ERP.nbin;
        else
            for b=1:length(Plot_bins)
                for i=1:length(ERP.bindescr)
                    if strcmpi(strtrim(Plot_bins{b}),strtrim(ERP.bindescr{i}))
                        Bin(b)= i; %finds locations etc
                    end
                end
            end

        end
    end
    % creating grand average
    ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(ALLERP));

    %% plotting grandmean
    ERP = pop_ploterps( ERP,Bin,plot_chan_num , ...
        'BinNum', 'on', 'Blc', 'pre', 'Box', [hor vert], ...
        'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', ...
        'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' }, 'LineWidth',1, 'Maximize', 'on', ...
        'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, ...
        'xscale', [epoch_time_x time_points_x], 'YDir', 'normal', ...
        'yscale', [amplitude_y amplitude_points_x]);
    print([home_path 'Grand_average_' Group_list{gr}], '-dpng' ,'-r300');
    close all
    %Saving grandmean
    ERP = pop_savemyerp(ERP, 'erpname', Group_list{gr},...
        'filename', [Group_list{gr} '.erp'], 'filepath', home_path, 'Warning', 'on');
    %renaming the bins, so they have the name of the group (needed for next plotting step)
    for i=1:size(ERP.bindescr,2)
        ERP.bindescr(i)={append(char(strtrim(ERP.bindescr(i))), ' ' , Group_list{gr})};
    end
    %for the final plot we need to rename the bins to have also the groupname
    for i=1:size(Plot_bins,2)
        Plot_binsgr=[Plot_binsgr {append(char(strtrim(Plot_bins(i))), ' ' , Group_list{gr})}];
    end

    GRERP = [GRERP,ERP]; %saving all the group ERPs
end



%% combining the grand averages of the group
ERP = pop_appenderp( GRERP , 'Erpsets', [ 1:size(GRERP,2)] );
%saving the erp of the groups together
ERP = pop_savemyerp(ERP, 'erpname', 'Groups_combined',...
    'filename', 'Groups_combined.erp', 'filepath', home_path, 'Warning', 'on');

%calculating how big the ERP figures can be

if  strcmpi(Plot_chans, 'All')
    plot_chan_num=1:64; %if all then simply 1:64
else
    %changing the names of the channels into the right numbers
    plot_chan_num = zeros(length(Plot_chans),1);
    for chan=1:length(Plot_chans) %for each inputted channel we loop
        for plt=1:ERP.nchan %across all channels that exist in the ERP set
            if strcmpi(Plot_chans{chan},ERP.chanlocs(plt).labels)
                plot_chan_num(chan) = ERP.chanlocs(plt).urchan; %finds locations etc
            end
        end
    end
    if length(Plot_chans) ~= length(nonzeros(plot_chan_num))
        error('Not all your input channels can be found in your data')
    end
    %transpose
    plot_chan_num=plot_chan_num';
end
%we now figure out the bins
bin=[];
if  strcmpi(Plot_bins, 'All')
    Bin=1:ERP.nbin;
else
    for b=1:length(Plot_binsgr) %looking at all the bins we want
        for i=1:length(ERP.bindescr) %if they are the same as all the bins that exist
            if strcmpi(Plot_binsgr{b},strtrim(ERP.bindescr{i}))
                Bin(b)= i;
            end
        end
    end
end
ERP = pop_ploterps( ERP,Bin,plot_chan_num , ...
    'BinNum', 'on', 'Blc', 'pre', 'Box', plot_tiles, ...
    'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', ...
    'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' }, 'LineWidth',1, 'Maximize', 'on', ...
    'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, ...
    'xscale', [epoch_time_x time_points_x], 'YDir', 'normal', ...
    'yscale', [amplitude_y amplitude_points_x]);
print([home_path 'Grand_average_all_groups'], '-dpng' ,'-r300');
