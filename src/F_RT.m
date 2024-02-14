% EEGLAB and ERPlab epoching script by Douwe Horsthuis on 2/9/2024
% This adds all the RTs together
% You get a file with the IDs,group,Condition,RTs
% it requires that the .erp file has been created using a binlist that
% stores reaction times
clear variables
eeglab
Group_RT=[]; % is needed to store the data
%add here all the names of your groups, this script can give you group plots
Group_list={'Name_grp1' 'Name_grp2'};
for gr=1:length(Group_list)
    if strcmpi(Group_list{gr},'Name_grp1')
        subject_list = {'ID_1' 'ID_2'};
    elseif strcmpi(Group_list{gr},'Name_grp2')
        subject_list = {'ID_3' 'ID_4'};
    else
        disp('not possible')
        pause()
    end
    home_path    = 'D:\whereisthedata\'; %place data is (something like 'C:\data\')
    save_path = 'D:\wheretosavethedata\'; %where to save the participants excel files with RTs
    %need to add the folder with the functions
    file_loc=[fileparts(matlab.desktop.editor.getActiveFilename),filesep];
    addpath(genpath(file_loc));%adding path to your scripts so that the functions are found
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '/'];
        %loading the ERP from the Epoching script it NEEDs to have been
        %created using a RT binlist, nothing else is extra needed
        ERP = pop_loaderp( 'filename', [subject_list{s} '_.erp'], 'filepath', data_path );
        %Using the standard RT function from ERPlab, saving both the excel
        %file as using the variable RT to put it on a group level together
        RT = pop_rt2text(ERP, 'eventlist',1, 'filename', [save_path subject_list{s} '_rt.xls'], 'header', 'on', 'listformat', 'basic' );
        %collect RT per bin

        for b= 1:2:7 %we want to look at bin 1,3,5,7 - this should be automated
            clear  RT_temp subject cond group; %completely get rid of these, they confuse the grouping process
            RT_temp(:,4)=num2cell(RT.EVENTLIST.bdf(b).rt) ; %this is the file that will dicate the length of all the other files. Is the all the RTs per bin as a row
            for q = 1:length(RT_temp) %adding the same variable for the lenght of the variable RT_temp
                subject{q} = subject_list{s};
                cond{q}    = RT.EVENTLIST.bdf(b).description;
                group{q}   = Group_list{gr};
            end
            RT_temp(:,1)=subject;
            RT_temp(:,2)=group;
            RT_temp(:,3)=cond;
            Group_RT=[Group_RT;RT_temp];
        end
    end

    filename_table = [home_path 'RTs.xlsx' ];
    writecell(Group_RT, filename_table); %saving excel with everyones info
    save([home_path 'participant_RT'], 'Group_RT'); %saving matlab file with everyones info


end