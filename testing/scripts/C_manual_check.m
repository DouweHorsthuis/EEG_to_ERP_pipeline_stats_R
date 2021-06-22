% Testing the scr code 6/21/2021
% ------------------------------------------------
subject_list = {'11' '14'};
home_path  = 'C:\Users\dohorsth\Documents\GitHub\EEG_to_ERP_pipeline_stats_R\testing\data\';
for s=1:length(subject_list)
    clear bad_chan;
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    pop_eegplot( EEG, 1, 1, 1);
    prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
    bad_chan = input(prompt); %
    if isempty(bad_chan) ~=1
    EEG = pop_select( EEG, 'nochannel',bad_chan);
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    close all
end
