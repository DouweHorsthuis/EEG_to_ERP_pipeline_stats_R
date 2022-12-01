%created by Pierfilippo De Sanctis
%on 2/28/2022 this script is edited so it works for the SFARI project by Douwe
%this script imports .xdf files and adds gait triggers to the data
%needs the xdfimport plugin (works with v1.18)
clear variables

eeglab
%% you need to add the path of the subfolder of the xdf plugin, otherwise eeglab will
%% not find the function (because we are not using pop_loadxdf, but a function inside the plugin)
addpath('C:\Users\douwe\OneDrive\Documents\MATLAB\eeglab2021.1\plugins\xdfimport1.18\xdf\')


data_path            = 'D:\OpticalFlow_sfari\';   %load
save_fig_path        = 'D:\OpticalFlow_sfari\figures\';   %save path for non-.set files

subj = {'12377' '12494' '12565' '12666' '12675'};


Cond = {'flow' 'no_flow' 'stand_no_flow'};

for cnd=1:length(Cond)
    switch Cond{cnd}
        case 'flow'
            cond = {'_flow_1' '_flow_2' '_flow_3'};
            Runs = {...    %number of blocks
                [1 2 3]...  % '12377'
                [1 2 3 ]...  % '12494' % keeps crashing
                [1 2 3]...  % '12565'
                [1 2 3]...  % '12666'
                [1 2 3]...  % '12675'
                };
        case 'no_flow'
            cond = {'_no_flow_1' '_no_flow_2' '_no_flow_3'};
            Runs = {...    %number of blocks
                [1 2 3]...  % '12377'
                [1 2 3]...  % '12494'
                [1 2 3]...  % '12565'
                [1 2 3]...  % '12666'
                [1 2 3]...  % '12675'
                };
            
        case 'stand_no_flow'
            cond = {'_stand_no_flow_1' '_stand_no_flow_2' '_stand_no_flow_3'};
            Runs = {...    %number of blocks
                [1 2]...  % '12377' has 3, but only using 2 since that's the norm
                [1 2]...  % '12494'
                [1 2]...  % '12565'
                [1 2]...  % '12666'
                [1]...  % '12675'
                };
            
            %   case 'stand_flow'
            %         cond = {'_stand_flow_1' '_stand_flow_2' '_stand_flow_3'};
            %         Runs = {...    %number of blocks
            %             [1 2]...  %
            %             };
    end
    
    % %use all the markers for now
    % optichans = {...     %number of chan per foot?? R & L?
    %     {[2 3]   [1 2 3 4]}...  % '12009' removed marker 1 right foot
    %     {[2 3]   [2 3]}...  % '12022' removed marker 4 right foot
    %     {[2 3]   [2 3 4]}...  % '12023'
    %     {[2 3]   [2 3]}...  % '12031' removed marker 4 right foot
    %     {[3]     [2 3 4]}...  % '12094' removed marker 2 right foot
    %     {[2 3]   [2 3]}...  % '12335' removed marker 4 right foot
    %     {[3]     [1 3]}...  % '12364' removed marker 2 and 4 right foot
    %     {[2 3]   [1 3]}...  % '12390' removed marker 4 right foot
    %     {[1 4]   [2 3]}...  % '12407'
    %     {[1 4]   [2 3]}...  % '12408' removed marker 3 right foot
    %     {[2 3]   [1 3]}...  % '12451' removed marker 4 right foot
    %     {[2 3 4] [1 3]}...  % '12457'
    %     {[2 3]   [2 3]}...  % '12458'
    %     {[2 3]   [2 3]}...  % '12459' removed marker 4 right foot
    %     {[4 6]   [5 6]}...  % '12468'
    %     {[2 3]   [2 3]}...  % '12478' removed marker 4 right foot
    %     };
    
    
    for subj_count = 1:length(subj)
        %mkdir([dire1 subj{subj_count} '\']);
        for al = Runs{subj_count}
            %a variable was causing the script not to run mulitple blocks in a
            %row, not sure which one, so deleting all
            clear velocityZleft3 FileHeader Streams t0 Optitime_stamps Optitime_series StepWidth_msec StepWidth_mm xdf_file xdf Optisrate sname imarkers aa ans bb C EDGES idx ik ind_edgeL ind_edgeR ind_edgeVZL ind_edgeVZR ind_outL ind_outR ind_temp indconst indJD indleftHS indLX indLY indLZ indo indpL indpR indpYL indpYR indrightHS indRX indRY indRZ iStepWidth JL JR leftHS leftToeoff loc markers MPD MPHL MPHR MUHAT N ol Opti_rel_timing Optitime_series3 rightHS rightToeoff SIGMAHAT StepWidth StepWidthLH StepWidthRH sw TFLX TFLY TFLZ TFRX TFRY TFRZ ThresholdL ThresholdR val_edgeL val_edgeR val_edgeVYL val_edgeVYR val_edgeVZL val_edgeVZR valJD valL valR valYL valYR velocityYleft3 velocityYright3  velocityZright3 VYL VYR VZL VZR Xleft Xright Yleft3 Yright3 Zleft3 Zright3
            
            xdf_file = [data_path subj{subj_count} '\' subj{subj_count} cond{al} '.xdf'];
            disp([ 'processing ' subj{subj_count} cond{al}])
            %% load xdf data streams and get relative timing using first Biosemi timestamp
            [Streams,FileHeader] = load_xdf(xdf_file);
            
            %% rename streams to identify biosemi and optitrack stream
            clear xdf
            for i = 1:length(Streams)
                sname = Streams{i}.info.name;
                xdf.(sname) = Streams{i};
            end
            t0 = xdf.BioSemi.time_stamps(1); % time 0 - first Biosemi timestamp
            
            %% resample optitrack timeseries to Biosemi sampling rate
            [Optitime_series,Optitime_stamps] = resample(xdf.OptiTrack.time_series',xdf.OptiTrack.time_stamps,str2double(xdf.BioSemi.info.nominal_srate));
            Optitime_series = Optitime_series';
            Optisrate = str2double(xdf.BioSemi.info.nominal_srate);
            % plot RF and LF xyz for subj
            subplot(3,1,1)
            plot(Optitime_series(13,:)); hold on
            plot(Optitime_series(14,:)); hold on
            plot(Optitime_series(15,:)); hold on
            plot(Optitime_series(25,:)); hold on
            plot(Optitime_series(26,:)); hold on
            plot(Optitime_series(27,:))
            legend ('L X', 'L Z', 'L Y', 'R X', 'R Z', 'R Y')
            set(gca,'fontsize', 18);
            subplot(3,1,2)
            plot(Optitime_series(13,:) - mean(Optitime_series(13,:),2)); hold on
            plot(Optitime_series(14,:) - mean(Optitime_series(14,:),2)); hold on
            plot(Optitime_series(15,:) - mean(Optitime_series(15,:),2)); hold on
            plot(Optitime_series(25,:) - mean(Optitime_series(25,:),2)); hold on
            plot(Optitime_series(26,:) - mean(Optitime_series(26,:),2)); hold on
            plot(Optitime_series(27,:) - mean(Optitime_series(27,:),2));
            subplot(3,1,3)
            plot(Optitime_series(13,:)); hold on
            plot(Optitime_series(25,:));
            set(gcf, 'Position',  [100, 100, 1000, 1000])
            saveas(gcf, [save_fig_path (subj{subj_count}) cond{al} '.tiff']);
            close all
            
            
            %% subtract first Biosemi timestamp from Optitrack timestamps to get latencies rel to EEG
            Opti_rel_timing = Optitime_stamps-t0;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get heelstrikes and toe offs from optitrack data
            %% find channels corresponding to left and right foot
            
            clear chanlabels
            for indo = 1:length(xdf.OptiTrack.info.desc.channels.channel)
                chanlabels{indo} = xdf.OptiTrack.info.desc.channels.channel{indo}.label;
            end
            if isrow(chanlabels); chanlabels = chanlabels'; end
            T = table(chanlabels);
            filename = [data_path 'All_sfari_chanlabels_Optitrack.xlsx'];
            
            writetable(T,filename,'Sheet',subj{subj_count}) % excel sheets all in one excel file
            
            
            
            TFRY = [];
            TFRZ = [];
            TFRX = [];
            TFLY = [];
            TFLZ = [];
            TFLX = [];
            
            for ik = 1:length(chanlabels)
                TFRY(ik) = (contains(chanlabels{ik}, 'Right_Foot') || contains(chanlabels{ik}, 'Right_foot')) && contains(chanlabels{ik}, 'Y');
                TFRZ(ik) = (contains(chanlabels{ik}, 'Right_Foot') || contains(chanlabels{ik}, 'Right_foot')) && contains(chanlabels{ik}, 'Z');
                TFRX(ik) = (contains(chanlabels{ik}, 'Right_Foot') || contains(chanlabels{ik}, 'Right_foot')) && contains(chanlabels{ik}, 'X');
                
                TFLY(ik) = (contains(chanlabels{ik}, 'Left_Foot') || contains(chanlabels{ik}, 'Left_foot')) && contains(chanlabels{ik}, 'Y');
                TFLZ(ik) = (contains(chanlabels{ik}, 'Left_Foot') || contains(chanlabels{ik}, 'Left_foot')) && contains(chanlabels{ik}, 'Z');
                TFLX(ik) = (contains(chanlabels{ik}, 'Left_Foot') || contains(chanlabels{ik}, 'Left_foot')) && contains(chanlabels{ik}, 'X');
                
            end
            indRZ = find(TFRZ == 1);
            indRY = find(TFRY == 1);
            indRX = find(TFRX == 1);
            indLZ = find(TFLZ == 1);
            indLY = find(TFLY == 1);
            indLX = find(TFLX == 1);
            
            %% Filter Optitrack data
            data = [];
            clear aa bb
            [bb,aa] = butter (4, [10] ./ (Optisrate / 2), 'low' );
            data= filtfilt(bb, aa, double(Optitime_series)');
            %figure;freqz(bb,aa,Optisrate, Optisrate) ;
            Optitime_series3 = data';
            
            data = [];
            clear aa bb
            [bb,aa] = butter (4, [0.1] ./ (Optisrate / 2), 'high' );
            data= filtfilt(bb, aa, double(Optitime_series3)');
            %figure;freqz(bb,aa,Optisrate, Optisrate) ;
            Optitime_series3 = data';
            
            %% select channels for left and right foot (not used?)
            %Yright = mean(Optitime_series(indRY(optichans{subj_count}{1}),:), 1);
            %Zright = mean(Optitime_series(indRZ(optichans{subj_count}{1}),:), 1);
            %Yleft = mean(Optitime_series(indLY(optichans{subj_count}{2}),:), 1);
            %Zleft = mean(Optitime_series(indLZ(optichans{subj_count}{2}),:), 1);
            
            
            %% calculate velocity data for vertical and A-P position data: displacement/time
            %% Right
            
            %only using selected optichans
            %Zright3 = mean(Optitime_series3(indRZ(optichans{subj_count}{1}),:), 1);
            %velocityZright3 = diff([Zright3(1) Zright3])./(1/Optisrate);
            %Yright3 = mean(Optitime_series3(indRY(optichans{subj_count}{1}),:), 1);
            %velocityYright3 = diff([Yright3(1) Yright3])./(1/Optisrate);
            
            %use all markers per foot
            Zright3 = mean(Optitime_series3(indRZ,:), 1);
            velocityZright3 = diff([Zright3(1) Zright3])./(1/Optisrate);
            Yright3 = mean(Optitime_series3(indRY,:), 1);
            velocityYright3 = diff([Yright3(1) Yright3])./(1/Optisrate);
            %% Left
            
            %only using selected optichans
            %Zleft3 = mean(Optitime_series3(indLZ(optichans{subj_count}{2}),:), 1);
            %velocityZleft3 = diff([Zleft3(1) Zleft3])./(1/Optisrate);
            %Yleft3 = mean(Optitime_series3(indLY(optichans{subj_count}{2}),:), 1);
            %velocityYleft3 = diff([Yleft3(1) Yleft3])./(1/Optisrate);
            
            %use all markers per foot
            Zleft3 = mean(Optitime_series3(indLZ,:), 1);
            velocityZleft3 = diff([Zleft3(1) Zleft3])./(1/Optisrate);
            Yleft3 = mean(Optitime_series3(indLY,:), 1);
            velocityYleft3 = diff([Yleft3(1) Yleft3])./(1/Optisrate);
            
            VZR = velocityZright3;
            VYR = velocityYright3;
            VZL = velocityZleft3;
            VYL = velocityYleft3;
            %plot(Optitime_series(13,:)); hold on
            %plot(Optitime_series3(13,:))
            %plot(Xleft3); hold on
            %plot(Xright3)
            
            %% get thresholds for finding peaks using the distribution of the vertical velocity data
            [MUHAT,SIGMAHAT] = normfit(VYR);
            MPHR = MUHAT+SIGMAHAT;
            
            [MUHAT,SIGMAHAT] = normfit(VYL);
            MPHL = MUHAT+SIGMAHAT;
            
            
            MPD = 250;  %sample points? peaks must be at least this far apart
            % get peaks in vertical velocity data for toe-off
            [valYR, indpYR] = findpeaks(VYR,'MinPeakHeight', MPHR, 'MinPeakDistance',MPD);
            [valYL, indpYL] = findpeaks(VYL,'MinPeakHeight', MPHL, 'MinPeakDistance',MPD);
            
            % get peaks in A-P velocity data for later detection of plateaus
            [valR, indpR] = findpeaks(VZR,'MinPeakHeight', MPHR, 'MinPeakDistance',MPD);
            [valL, indpL] = findpeaks(VZL,'MinPeakHeight', MPHL, 'MinPeakDistance',MPD);
            
            
            %% find plateaus in the velocity profile of the A-P data
            JR = stdfilt(VZR, [ones((7*6)+1,1)']);
            JL = stdfilt(VZL, [ones((7*6)+1,1)']);
            
            
            [N,EDGES] = histcounts(JR, 100);round(size(JR,2)/10);
            [valJD, indJD] = max(N);
            ThresholdR = EDGES(indJD+1);
            
            [N,EDGES] = histcounts(JL, 100);round(size(JL,2)/10);
            [valJD, indJD] = max(N);
            ThresholdL = EDGES(indJD+1);
            %
            
            %% find indexes for Heelstrikes
            % right HS
            ind_edgeR = [];
            
            for ol = 1:length(indpYR)-1
                ind_temp = indpYR(ol):indpYR(ol+1);
                indconst = find(JR(indpYR(ol):indpYR(ol+1)) < ThresholdR);
                if isempty(indconst)
                    ind_edgeR(ol) = ind_temp(1);
                else
                    ind_edgeR(ol) = ind_temp(indconst(1));%ind_temp(indconst(indconst_temp(indedge))+1);
                end
            end
            
            %left HS
            ind_edgeL = [];
            
            for ol = 1:length(indpYL)-1
                ind_temp = indpYL(ol):indpYL(ol+1);
                indconst = find(JL(indpYL(ol):indpYL(ol+1)) < ThresholdL);
                if isempty(indconst)
                    ind_edgeL(ol) = ind_temp(1);
                else
                    ind_edgeL(ol) = ind_temp(indconst(1));%ind_temp(indconst(indconst_temp(indedge))+1);
                end
            end
            
            
            
            val_edgeR = JR(ind_edgeR);
            val_edgeVZR = VZR(ind_edgeR-(6*7/2));
            
            ind_edgeVZR = ind_edgeR-(6*7/2);
            val_edgeVYR = VYR(ind_edgeR-(6*7/2));
            
            val_edgeL = JL(ind_edgeL);
            val_edgeVZL = VZL(ind_edgeL-(6*7/2));
            ind_edgeVZL = ind_edgeL-(6*7/2);
            val_edgeVYL = VYL(ind_edgeL-(6*7/2));
            %
            %% get index for heelstrikes to remove
            ind_outR = find((ind_edgeVZR-indpYR(1:end-1) > median(ind_edgeVZR-indpYR(1:end-1))+3*(std(ind_edgeVZR-indpYR(1:end-1))))...
                | (ind_edgeVZR-indpYR(1:end-1) < median(ind_edgeVZR-indpYR(1:end-1))-3*(std(ind_edgeVZR-indpYR(1:end-1))))...
                | (VYR(ind_edgeVZR) < median(VYR(ind_edgeVZR))-2*std(VYR(ind_edgeVZR)))...
                | (VYR(ind_edgeVZR) > median(VYR(ind_edgeVZR))+2*std(VYR(ind_edgeVZR)))...
                | (VZR(ind_edgeVZR) > 0));
            
            ind_outL = find((ind_edgeVZL-indpYL(1:end-1) > median(ind_edgeVZL-indpYL(1:end-1))+3*(std(ind_edgeVZL-indpYL(1:end-1))))...
                | (ind_edgeVZL-indpYL(1:end-1) < median(ind_edgeVZL-indpYL(1:end-1))-3*(std(ind_edgeVZL-indpYL(1:end-1))))...
                | (VYL(ind_edgeVZL) < median(VYL(ind_edgeVZL))-2*std(VYL(ind_edgeVZL)))...
                | (VYL(ind_edgeVZL) > median(VYL(ind_edgeVZL))+2*std(VYL(ind_edgeVZL)))...
                | (VZL(ind_edgeVZL) > 0));
            
            %% get index for heelstrikes to keep
            indrightHS = find(ismember(ind_edgeVZR,ind_outR) == 0) ;
            indleftHS = find(ismember(ind_edgeVZL,ind_outL) == 0) ;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get latency of heelstrikes from relative timing to Biosemi data
            
            %% create marker structure and get latency from relative timing to Biosemi data
            
            %%CHANGE THE EVENT CODES TO GET UNIQUE #s FOR EVERY CONDITION
            
            if strcmp(Cond{cnd},'flow')
                rightHS = [Opti_rel_timing(ind_edgeVZR(indrightHS))' ones(size(ind_edgeVZR(indrightHS)))'*100];
                leftHS = [Opti_rel_timing(ind_edgeVZL(indleftHS))' ones(size(ind_edgeVZL(indleftHS)))'*101];
                rightToeoff = [Opti_rel_timing(indpYR)' ones(size(indpYR))'*102];
                leftToeoff = [Opti_rel_timing(indpYL)' ones(size(indpYL))'*103];
                markers = [rightHS;leftHS;rightToeoff;leftToeoff];
            elseif strcmp(Cond{cnd},'no_flow')
                rightHS = [Opti_rel_timing(ind_edgeVZR(indrightHS))' ones(size(ind_edgeVZR(indrightHS)))'*200];
                leftHS = [Opti_rel_timing(ind_edgeVZL(indleftHS))' ones(size(ind_edgeVZL(indleftHS)))'*201];
                rightToeoff = [Opti_rel_timing(indpYR)' ones(size(indpYR))'*202];
                leftToeoff = [Opti_rel_timing(indpYL)' ones(size(indpYL))'*203];
                markers = [rightHS;leftHS;rightToeoff;leftToeoff];
                
            elseif strcmp(Cond{cnd},'stand_no_flow')
                rightHS = [Opti_rel_timing(ind_edgeVZR(indrightHS))' ones(size(ind_edgeVZR(indrightHS)))'*300];
                leftHS = [Opti_rel_timing(ind_edgeVZL(indleftHS))' ones(size(ind_edgeVZL(indleftHS)))'*301];
                rightToeoff = [Opti_rel_timing(indpYR)' ones(size(indpYR))'*302];
                leftToeoff = [Opti_rel_timing(indpYL)' ones(size(indpYL))'*303];
                markers = [rightHS;leftHS;rightToeoff;leftToeoff];
            elseif strcmp(Cond{cnd},'stand_flow')
                rightHS = [Opti_rel_timing(ind_edgeVZR(indrightHS))' ones(size(ind_edgeVZR(indrightHS)))'*400];
                leftHS = [Opti_rel_timing(ind_edgeVZL(indleftHS))' ones(size(ind_edgeVZL(indleftHS)))'*401];
                rightToeoff = [Opti_rel_timing(indpYR)' ones(size(indpYR))'*402];
                leftToeoff = [Opti_rel_timing(indpYL)' ones(size(indpYL))'*403];
                markers = [rightHS;leftHS;rightToeoff;leftToeoff];
            end
            %% Step width
            Xright = mean(Optitime_series(indRX,:), 1);
            Xleft = mean(Optitime_series(indLX,:), 1);
            for sw = indrightHS
                StepWidthRH(sw) = Xright(ind_edgeVZR(sw)) - Xleft(ind_edgeVZR(sw));
            end
            for sw = indleftHS
                StepWidthLH(sw) = Xleft(ind_edgeVZL(sw))  - Xright(ind_edgeVZL(sw));
            end
            stem(StepWidthRH); hold on
            stem(StepWidthLH)
            legend('StepW RHeelSt', 'StepW LHeelSt')
            set(gca,'fontsize',18);
            saveas(gcf, [ save_fig_path (subj{subj_count}) cond{al}  '_StepWidth.tiff']);
            close all
            
            StepWidth_mm   = [abs(StepWidthRH), StepWidthLH];
            StepWidth_msec = [Opti_rel_timing(ind_edgeVZR), Opti_rel_timing(ind_edgeVZL)];
            StepWidth      = [StepWidth_msec; StepWidth_mm]';
            StepWidth      = sortrows(StepWidth);
            %% merge marker with StepWidth matrix
            [~,imarkers,iStepWidth] = intersect(markers(:,1),StepWidth(:,1));
            C = [markers(imarkers,1:2),StepWidth(iStepWidth,2)];
            [idx,loc]=ismember(markers(:,1),StepWidth(:,1));
            markers(idx,3)=StepWidth(loc(idx),2);
            %% load EEG data
            EEG = pop_loadxdf(xdf_file, 'streamtype', 'EEG', 'exclude_markerstreams', {});
            EEG = eeg_checkset( EEG );
            
            %% remove channels from EEG data
            %64 channels
            EEG = pop_select  ( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'});
            EEG = eeg_checkset( EEG );
            %%%%%%%%%%%%%%%%%%%%%%%%%%  import markers to eeglab
            %% import markers to eeglab
            [EEG] = pop_importevent(EEG, 'event', ...
                markers, 'fields', {'latency', 'type', 'StepWidth'}, ...
                'append', 'yes', 'timeunit', 1);
            
            %save in ind ss folders
            pop_saveset( EEG, 'filename',[ subj{subj_count} cond{al} '.set'],...
                'filepath', [data_path subj{subj_count}]);
            
        end
    end
end
%% Combining the separate .set files in one big continues file
for subj_count = 1:length(subj)
    eeglab
    folder_index=dir([data_path subj{subj_count}]);
    block_info= [];
    for i=length(folder_index):-1:3
        if strcmp(folder_index(i).name(end-2:end),'set')
            disp(['**************************************      loading ' folder_index(i).name '      **************************************'])
            EEG = pop_loadset('filename',folder_index(i).name, 'filepath', [data_path subj{subj_count} '\']);
            block_info= [block_info; string(EEG.filename(7:end-4)), round(EEG.xmax)];
            [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
    end
    EEG = pop_mergeset( ALLEEG, 1:length(ALLEEG), 0);
    EEG.subject = subj{subj_count};
    EEG.mobi_info= block_info;
    EEG.setname='MoBI optical flow sfari';
    EEG = pop_saveset( EEG, 'filename',[subj{subj_count} '.set'],'filepath',[data_path subj{subj_count} '\']);
end
