clear variables
eeglab
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
    end
    % creating grand average
    ERP = pop_gaverager( ALLERP , 'Erpsets', 1:length(ALLERP));
    %Saving grandmean
    ERP = pop_savemyerp(ERP, 'erpname', Group_list{gr},...
        'filename', [Group_list{gr} '.erp'], 'filepath', home_path, 'Warning', 'on');
    %% plotting grandmean
    ERP = pop_ploterps( ERP,1:5,1:64 ,  'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 8 8], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' , 'g-' , 'c-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', [ 103.714 28 106.857 31.9412], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, 'xscale', [ -50.0 394.0 -25 0:100:300 ], 'YDir', 'normal', 'yscale', [ -4.0 10.0   -10:2.5:10 ]);
end