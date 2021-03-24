# EEG-Raw-to-ERP (BIOSEMI)
General pipeline used for analyzing EEG data where Raw EEG data gets transformed into ERPS
This pipeline is created and updated between 2017-2021. It uses Matlab and needs the plugin EEGlab and ERPlab to function. 
The pipeline has 5 script that can be run after eachother. 

Script 1 (A_merge_sets) loads the .BDF files potentially merging them if there are multiple per participant and creates individual .set files for next step
Script 2 (B_downs_filter_chaninfo_exclextern_exclchan) downsamples (256hz) Highpass (filter 1hz) Lowpass filter (45hz), excludes externals, auto channels rejection based on a kurtosis threshold.
Script 3 (C_avgref_ica_autoexcom) This scripts does an average reference, uses runica and IClabel to created IC components and defines and deletes the bad ones. The bad components also get printed. Bad IC components are definde by IClable if they contain more than 80% of a combination of muscle, eye, heart, line noise and channel noise and less than 5% brain 
Script 4 (D_interpolate) it interpolates the channels and creates a file which channels were deleted for which participant
Script 5 (E_epoching) it epochs the continues data, runs a last cleaning where it deletes all the epochs that are too noisy (this amount gets saved for each participant) saves the data as both .erp and .set
events.txt this file is used in script 5. it can be created by using ERP lab, but it needs all the triggers from the data that are relevant, assigns a name to them and a bin. (example: 101 "first trigger" 1 "first trigger" 102 "last trigger" 2 "last trigger")
