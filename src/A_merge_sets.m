% EEGLAB merge sets modified from Ana on 2017-07-11
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_biosig('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\12459\12459_visualgating_1.bdf', 'ref',[67 68] ,'refoptions',{'keepref' 'off'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','12459_1','gui','off'); 
EEG = pop_saveset( EEG, 'filename','12459_1.set','filepath','\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\12459\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_biosig('\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\12459\12459_visualgating_2.bdf', 'ref',[67 68] ,'refoptions',{'keepref' 'off'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','12459_2','gui','off'); 
EEG = pop_saveset( EEG, 'filename','12459_2.set','filepath','\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\12459\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_mergeset( ALLEEG, [1   2  ], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','12459','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','12459.set','filepath','\\data.einsteinmed.org\users\Ana and Douwe\22Q\Visual gating\Data\12459\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
12459