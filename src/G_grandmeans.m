clear variables
eeglab
%% Input for the grandmeans
Plot_chans={'chn1' 'chn2'}; %either channel names e.g. {'fpz' 'F1'} or {'All'}
Plot_bins={'bin1name' 'bin2name'}; %either names from ERP.bindescr or 'All' 
epoch_time_x = [start endtime]; %time in ms e.g. [-50 100]
time_points_x = [timeseries]; %Time point for the plot in ms -> individual times eg. [-50 10 12 200 322] steps [ 0:50:300] combo [-50 0:100:300]
amplitude_y = [min_y max_y]; % e.g. [ -4.0 10.0]
amplitude_points_x = [ampltseries]; %Amplitude on y-axis similar to time_point_x 
%% Subject info for each script
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
    home_path    = 'D:\whereisthedata\'; %place data is (something like 'C:\data\')
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
    %calculating how big the ERP figures can be 
    x=size(plot_chan_num,2);
    hor=ceil(sqrt(x)); vert=floor(sqrt(x));
    % creating grand average
    ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(ALLERP));
    %Saving grandmean
    ERP = pop_savemyerp(ERP, 'erpname', Group_list{gr},...
        'filename', [Group_list{gr} '.erp'], 'filepath', home_path, 'Warning', 'on');
    %% plotting grandmean
    ERP = pop_ploterps( ERP,Bin,plot_chan_num , ...
        'BinNum', 'on', 'Blc', 'pre', 'Box', [hor vert], ...
        'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', ...
        'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' }, 'LineWidth',1, 'Maximize', 'on', ...
        'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, ...
        'xscale', [epoch_time_x time_points_x], 'YDir', 'normal', ...
        'yscale', [amplitude_y amplitude_points_x]);
end