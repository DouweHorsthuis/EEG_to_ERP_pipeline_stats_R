% EEGLAB merge sets, and creates .set file
% by Douwe Horsthuis on 3/24/2021
% ------------------------------------------------
subject_list = {'some sort of ID' 'a different id for a different particpant'}; %all the IDs for the indivual particpants
filename= 'the_rest_of_the_file_name'; % if your bdf file has a name besides the ID of the participant
home_path  = 'path_where_to_load_in_pc'; %place data is
blocks = 5; % the amount of BDF files. if different participant have different blocks, run the separate
ref_chan = [65 66]; % these are normally the mastoids. BIOSEMI should have ref, but you can load it without
for s = 1:length(subject_list)
clear ALLEEG
eeglab
close all
data_path  = [home_path subject_list{s} '\'];
disp([data_path  subject_list{s} '_' filename '.bdf'])
if blocks == 1
    EEG = pop_biosig([data_path  subject_list{s} '_' filename '.bdf'], 'ref', ref_chan ,'refoptions',{'keepref' 'off'}); %
else
    for bdf_bl = 1:blocks
        EEG = pop_biosig([data_path  subject_list{s} '_' filename '_' num2str(bdf_bl) '.bdf'], 'ref', ref_chan ,'refoptions',{'keepref' 'off'}); %
    end
    EEG = pop_mergeset( ALLEEG, [1:blocks], 0);
end
EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end 
