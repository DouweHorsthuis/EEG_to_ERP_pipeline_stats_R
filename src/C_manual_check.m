% Plotting the raw data to see if there are remaining bad or flat channels
% Created by Douwe Horsthuis last update 5/7/2021
% ------------------------------------------------

subject_list = {'some sort of ID' 'a different id for a different particpant'};
home_path  = 'the main folder where you store your data';
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    bad_chan = [];
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
