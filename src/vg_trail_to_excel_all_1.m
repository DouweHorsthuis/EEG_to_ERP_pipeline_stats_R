%b995eated on 8/27/2018 By Douwe For Ana
%Sb995ipt will take
%1) the means of paradigm epoched data, in a defined time window, for a selected channel
%2)asign a number to the condition
%3)assign a trail number to every individual mean
%4)assign a number for what group the participants belong to
%5)put this in a matlab table
% use the script called trail_to_excel_2 to transfer this to an excel sheet

close all
clear all
eeglab
group = 'TD1';
path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';



switch group
    case 'TD1' %TD1 = 22q controls
        subj    =  {'10092' '10130' '10149' '10172' '10214' '10394' '10476' '10581' '10585' '10590' '10640' '10748' '10780' '10784' '10862' '10888' '10915' '12004' '12005' '12006' '12012' '12215' '12313' '12328' '12512' '12313' '12328' '12512' '12549' '12648' '12666' '12727' '12746' '12750' '12755' '12770' '12815' '12852' '12858'};%
    case 'TD2' %TD2 = sz controls
        subj    = {'10967' '12004' '12012' '12139' '12177' '12188' '12197' '12203' '12206' '12215' '12230' '12272' '12313' '12329' '12433' '12449' '12482' '12588' '12666' '12707' '12770' '12852' '12870'};
    case '22q'
        subj    = {'2201' '2202' '2204' '2207' '2208' '2212' '2216' '2217' '2220' '2221' '2222' '2223' '2229' '2231' '2236' '2237' '2238' '2243' '2247' '2250' '2254' '2256' '2257' '2261' '2262' '2267' '2274' '2281' '2284' '2285' '2286' '2292' '2295' '2297'}; %
    case 'SZ'
        subj    = {'7003' '7007' '7019' '7025' '7046' '7048' '7049' '7051' '7054' '7058' '7059' '7061' '7063' '7064' '7073' '7074' '7075' '7078' '7089' '7092' '7123' '7556' '7808'};
        
end

data_temp = [];
for subj_count = 1:length(subj)
    %% loading data and separating the epochs
    % Path to the folder containing the current Subject's data
    data_path  = [path subj{subj_count} '/'];
    %loading data set
    EEG  = pop_loadset('filename', [subj{subj_count} '_all.set'], 'filepath', data_path , 'loadmode', 'all');
    % separating the epochs
    EEG145  = pop_selectevent( EEG, 'type',{'B1(145)'},'deleteevents','on','deleteepochs','on','invertepochs','off');
    EEG245  = pop_selectevent( EEG, 'type',{'B2(245)'},'deleteevents','on','deleteepochs','on','invertepochs','off');
    EEG495  = pop_selectevent( EEG, 'type',{'B3(495)'},'deleteevents','on','deleteepochs','on','invertepochs','off');
    EEG995  = pop_selectevent( EEG, 'type',{'B4(995)'},'deleteevents','on','deleteepochs','on','invertepochs','off');
    EEG2495 = pop_selectevent( EEG, 'type',{'B5(2495)'},'deleteevents','on','deleteepochs','on','invertepochs','off');
    %% b995eating means for amplitude for a specific channel
    
    %Fp1	=	1;
    %AF7	=	2;
    %AF3	=	3;
    %F1	=	4;
    %F3	=	5;
    %F5	=	6;
    %F7	=	7;
    %FT7	=	8;
    %FC5	=	9;
    %FC3	=	10;
    %FC1	=	11;
    %C1	=	12;
    %C3	=	13;
    %C5	=	14;
    %T7	=	15;
    %TP7	=	16;
    %CP5	=	17;
    %CP3	=	18;
    %CP1	=	19;
    %P1	=	20;
    %P3	=	21;
    %P5	=	22;
    %P7	=	23;
    %P9	=	24;
    %PO7	=	25;
    %PO3	=	26;
    %O1	=	27;
    %Iz	=	28;
    Oz	=	29;
    %POz	=	30;
    %Pz	=	31;
    %CPz	=	32;
    %Fpz	=	33;
    %Fp2	=	34;
    %AF8	=	35;
    %AF4	=	36;
    %AFz	=	37;
    %Fz	=	38;
    %F2	=	39;
    %F4	=	40;
    %F6	=	41;
    %F8	=	42;
    %FT8	=	43;
    %FC6	=	44;
    %FC4	=	45;
    %FC2	=	46;
    %FCz	=	47;
    %Cz	=	48;
    %C2	=	49;
    %C4	=	50;
    %C6	=	51;
    %T8	=	52;
    %TP8	=	53;
    %CP6	=	54;
    %CP4	=	55;
    %CP2	=	56;
    %P2	=	57;
    %P4	=	58;
    %P6	=	59;
    %P8	=	60;
    %P10	=	61;
    %PO8	=	62;
    %PO4	=	63;
    %O2	=	64;
    %specify the begin and end points of the time window of interest
    time_window = [165 205];
    
    % find the samples within this time window for Hit condition
    samples145 = find( EEG145.times>=time_window(1) & EEG145.times<=time_window(2) );
    % pull out the data from this range of samples, and average over samples
    % for 145 condition
    means145 = squeeze( mean( EEG145.data( Oz, samples145, : ), 2 ) );
    %do the same for other conditions
    sampels245 = find( EEG245.times>=time_window(1) & EEG245.times<=time_window(2) );
    means245 = squeeze( mean( EEG245.data( Oz, sampels245, : ), 2 ) );
    
    samples495 = find( EEG495.times>=time_window(1) & EEG495.times<=time_window(2) );
    means495 = squeeze( mean( EEG495.data( Oz, samples495, : ), 2 ) );
    
    samples995 = find( EEG995.times>=time_window(1) & EEG995.times<=time_window(2) );
    means995 = squeeze( mean( EEG995.data( Oz, samples995, : ), 2 ) );
    
    samples2495 = find( EEG2495.times>=time_window(1) & EEG2495.times<=time_window(2) );
    means2495 = squeeze( mean( EEG2495.data( Oz, samples2495, : ), 2 ) );
    
    
    %% Condition
    b145 = 0; b245 = 0; b495 = 0; b995 = 0; b2495 = 0;
    b145(1:length(means145))     = 1;
    b245(1:length(means245))    = 2;
    b495(1:length(means495))    = 3;
    b995(1:length(means995))    = 4;
    b2495(1:length(means2495))   = 5;
    Condition      = [b145, b245, b495, b995, b2495]; 
    if isrow(Condition); Condition = Condition'; end
    
    %% Trial creating a counter for every trial
    
    
    b145_tr = (1:length(means145));
    b245_tr = (1:length(means245));
    b495_tr = (1:length(means495));
    b995_tr = (1:length(means995));
    b2495_tr= (1:length(means2495));
    Trial = [b145_tr, b245_tr, b495_tr, b995_tr, b2495_tr]; % 
    if isrow(Trial); Trial = Trial'; end
    %% ERP data -here we can combine the means of diff conditions
    Erp = [means145; means245; means495; means995; means2495]; 
    %% Subject - calls all of them the total n of subjects not individ ID
   
    subject =1:length(Erp);
    
    if strcmp(group,'TD1')
        subject(1:length(Erp))      = subj_count;
    elseif strcmp(group,'22q')
        %+27 to go after first group of TD1
        subject(1:length(Erp))      = subj_count+27;
    elseif strcmp(group,'TD2')
        %+54 to go after first 2 groups
        subject(1:length(Erp))      = subj_count+54;
    else
        %+69 to go after first 3 groups
        subject(1:length(Erp))      = subj_count+69;
    end
    if isrow(subject); subject = subject'; end
    %% combining
    
    data_subj                  = [subject, Condition, Trial, Erp];
    data_temp                  = [data_temp; data_subj];
end

%% group

if strcmp(group,'TD1')
    Group(1:length(data_temp)) = 1;
elseif strcmp(group,'22q')
    Group(1:length(data_temp)) = 2;
elseif strcmp(group,'TD2')
    Group(1:length(data_temp)) = 3;
else %sz group
    Group(1:length(data_temp)) = 4;
end
if isrow(Group); Group = Group'; end

data = [Group, data_temp];
%% saving the tables files
if strcmp(group,'TD1')
    data_TD1 = data;
    save('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\data_TD1')
elseif strcmp(group,'22q')
    data_22q = data;
    save('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\data_22q')
elseif strcmp(group,'TD2')
    data_TD2 = data;
    save('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\data_TD2')
else
    data_SZ = data;
    save('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\\data_SZ')
    
end



