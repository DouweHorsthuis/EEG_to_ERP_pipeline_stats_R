eeglab

% This defines the set of subjects
subject_list = {'2201','2202','2204','2207','2208','2212','2216','2217','2220','2221','2222','2223','2229','2231','2236','2237','2238','2243','2247','2250','2252','2254','2256','2257','2261','2262','2267','2270','2274','2281','2284','2285','2286','2292','2295','2297','7003','7007','7019','7025','7046','7048','7049','7051','7054','7058','7059','7061','7063','7064','7073','7074','7075','7078','7089','7092','7123','7556','7808','10092','10130','10149','10172','10214','10360','10394','10446','10463','10476','10581','10585','10590','10640','10748','10780','10784','10862','10888','10915','10967','12004','12005','12006','12007','12012','12038','12139','12177','12188','12197','12203','12206','12215','12230','12272','12313','12328','12329','12413','12433','12449','12482','12512','12549','12588','12648','12666','12707','12727','12746','12750','12755','12770','12815','12852','12858','12870'};%
nsubj = length(subject_list); % number of subjects

% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\';

% Loop through all subjects
for s=1:nsubj
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];

       % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s})
    
    EEG = pop_loadset('filename', [subject_list{s} '_downft.set'], 'filepath', data_path);
    EEG=pop_chanedit(EEG, 'lookup','C:\Users\dohorsth\Documents\Matlab\eeglab2019_1\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exext.set'],'filepath', data_path);
    
    end;

    
    
  