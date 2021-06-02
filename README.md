[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R">
    <img src="images/CNL_logo_2.jpeg" alt="Logo" width="286" height="120">
  </a>

  <h3 align="center">EEG pipeline using EEGlab</h3>

  <p align="center">
    This EEG pipeline is made to analyze data collected with a biosemi system, using however many channels you want. There are several cleaning steps (e.g. channel rejection, ICA, epoch rejection) after which stats can be done using R studio. This pipeline contain several scripts, organized alphabetically. Each script runs a loop on all the participants, making sure that the same steps are taken for each participant. The reason it is not one big script is, because after running each script it would be a good moment to check if you are happy with the data. 
    <br />
    <br />
    <br />
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues">Report a Bug</a>
    .
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues">Request Feature</a>
  </p>
</p>

1. [About the project](#about-the-project) 
    - [Built With](#built-with)
2. [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Usage](#usage)
3. [Pipeline roadmap](#pipeline-roadmap)
    - [Pre-processing](#pre-processing)
      - [A_merge_sets(Matlab)](#a_merge_sets)
      - [B_downs_filter_chaninfo_exclextern_exclchan(Matlab)](#b_downs_filter_chaninfo_exclextern_exclchan)
        - [Filtering](#filtering)
      - [C_manual_check(Matlab)](#c_manual_check)
      - [D_avgref_ica_autoexcom(Matlab)](#d_avgref_ica_autoexcom)
      - [E_interpolate(Matlab)](#e_interpolate)
      - [F_epoching(Matlab)](#f_epoching)
    - [exporting](#exporting)
      - [F_individual_trials_export(Matlab)](#f_individual_trials_export)
    - [Statistics](#statistics)
      - [Loading and setting up the structure(Rstudio)](#loading-and-setting-up-the-structure)
      - [Statistics (including mixed-effects models)(Rstudio)](#statistics-including-mixed-effects-models)
3. [Contributing](#contributing)
3. [Updates](#updates)
3. [Publications using this pipeline](#publications-using-this-pipeline-only-including-papers)
3. [License](#license)
3. [Contact](#contact)
3. [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

This EEG pipeline is made to analyze data collected with a biosemi system, using however many channels you want. There are several cleaning steps (e.g. channel rejection, ICA, epoch rejection) after which stats can be done using R studio. It is scalable to multiple groups and variables such as filter strength, and rejection thresholds are changeable, but are pre-tested and worked for multiple publications.


### Built With

* [Matlab](https://www.mathworks.com/)
* [EEGlab](https://sccn.ucsd.edu/eeglab/index.php)
* [ERPlab](https://github.com/lucklab/erplab) (EEGlab plugin)
* [Rstudio](https://www.rstudio.com/)



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these steps.

### Prerequisites
Software: You need to have a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php) (these scripts works for version eeglab2019_1)

You need to install the [ERPlab](https://erpinfo.org/erplab) plugin. (these scripts work with erplab8.01)

### Installation
Download a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php). 

To install the ERPlab, either download it from [Github](https://github.com/lucklab/erplab/releases) and save it in the "Plugins" folder in EEGlab, or open EEGlab and download it via File-->Manage EEGLAB extension and look for ERPlab.


<!-- USAGE EXAMPLES -->
### Usage
To use EEGlab you need to set the path to include this folder and all it's sub folders:

[In matlab, set path --> add with Subfolders... -->the main eeglab folder --> close](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab/blob/main/images/screenshot_add_path.PNG)
Or you can hard core this: 

```matlab
addpath(genpath('theplacewhereyouhavethefolder\eeglab2019_1\'));
```


<!-- ROADMAP -->
## Pipeline roadmap
Here you'll see what each script does and what variables you can need to change.

## Pre-processing

### A_merge_sets
In this script EEGlab will look for all the .bdf or .edf files for all the IDs you enter. Even if you only have one file per participant, you need to run them through this script, because you end up with .set files that have the EEGlab structure in them.
Besides, defining the home/save path, you can choose how many blocks (or .BDF files) your participants have. Normally everyone does the same amount of blocks so this would be the same for everyone, but if not, you need to run that participant separately. 
Furthermore, you can choose a reference channel. This is suggested by [BIOsemi](https://www.biosemi.com/faq/cms&drl.htm). In our case we use the mastoids (channel 65/66 for us), but you can change this to a different channel or leave it empty if you don't want to do this.


These are the variables to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
filename= 'the_rest_of_the_file_name';  
home_path  = 'path_where_to_load_in_pc'; 
save_path  = 'path_where_to_save_in_pc'; 
blocks = 5; 
ref_chan = [65 66] 
```

### B_downs_filter_chaninfo_exclextern_exclchan
This script starts by loading the previously created .set file, so you need to set the home_path to where you saved the data and the new data will also be saved there. 
The first thing the script does is down-sample to 256 Hz. We collect data at 512Hz, and there is no real reason to keep it at this high resolution. 

The second step is a 1Hz high-pass filter. To change this you need to also decide on the filter order. [See this for more info](https://github.com/widmann/firfilt/blob/master/pop_eegfiltnew.m)

Same counts for the third step, which is a 45Hz high-pass filter.

To optimize the ICA solutions, these are the suggested filters. However, if you want to look at components that show up later in the data, 1Hz might be too high. [See this paper for more info on filters.](https://www.sciencedirect.com/science/article/pii/S0896627319301746)

The fourth step is adding information to the channels. This is why you need to define the path to EEGlab or to the 'biosemi160' file. It will look for a file to import the channel information. After which it will delete the externals. The difference between the two paths has to do with that for 64channels we use a 10-20 layout for the BIOsemi caps, however for the 160channel caps we have a spherical layout. The first file is part of EEGlab, but this is not the case for the 160channel cap. 64channels is defined as 64 to 95, because a full extra ribbon would be 96 channels. In or lab we normally go up to 8 channels, but we have data that has more. This takes that in consideration. 

Lastly, in step 5, it will reject all the channels based on a kurtosis threshold. It is set to 5, which is the standard. 


These are the variables you NEED to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
eeglab_location = 'C:\Users\wherever\eeglab2019_1\'; %needed if using a 10-5-cap
scripts_location = 'C:\\Scripts\'; %needed if using 160channel data
home_path  = 'the main folder where you store your data';
```

These you can change if you want to change settings
```matlab
EEG = pop_resample( EEG, 256); %downsampling
EEG = pop_eegfiltnew(EEG, [],1,1690,1,[],1); % High pass filter
EEG = pop_eegfiltnew(EEG, [],45,152,0,[],1); % Low  pass filter
EEG = pop_chanedit(EEG, 'lookup',[eeglab_location 'plugins\dipfit\standard_BESA\standard-10-5-cap385.elp']); 
EEG = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'});% To delete different channels if needed 
EEG = pop_rejchan(EEG ,'threshold',5,'norm','on','measure','kurt'); %the rejection threshold (standard is 5)
```
#### Filtering 
You do not need to follow the filtering in this script. EEGlab makes it relatively easy to created/use new filters. 

##### Using a new filter in EEGlab
If you want to change your filter the easiest way, you open a random .set file. and do the following 3 steps:  

![step1](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Open_filter.PNG "open")  
![step2](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/filter%20inputs.PNG "input")  
Here you input the Filter you want. To create a 1Hz filter, you input the number 1 in the "lower edge of the frequency pass band (Hz)" box and hit "ok"  
![step3](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/figure%20out%20filter%20order.PNG "output")  
This shows up in Matlab. Replace the filter number with the number 1. followed by the number "preforming [number] point highpass filter" -1 as the filter order. 
##### What filter should I choose
Choosing what filters to use will have a big inpact on your data. There are a couple things to consider because filters will have impact in several different ways on your data. 
**ICA** The [EEGlab people](https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline#High-pass_filter_the_data_at_1-Hz_.28for_ICA.2C_ASR.2C_and_CleanLine.29.2809.2F23.2F2019_updated.29) suggest using a 1hz and 45hz filter to get the best ICA solutions. But if one only uses the ICA for removing eyeblinks and eyemovement it might be worth it to think more.
###### Lowpass filter 
We usually use a lowpass filter to get rid of high frequency noise that cannot be caused by the brain. By using a 45hz filter this can be solved.Unless you are intressted in specific frequencies that go above 40Hz it's normally safe to use it. 
This is what the filter will do to data:  
![45hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-45hz.jpg "45hz")  
The black line is downsampled like the Red line + a 45Hz filter is ran on it. If you look at the zoomed in parts it is clear the this smooths out the ERP. 
###### Highpass filter
A highpass filter is used to stop Baseline drift. [This drift is stronger for kids and some patient populations (0.1Hz) then for Adult subjects (0.01Hz).](https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline#High-pass_filter_the_data_at_1-Hz_.28for_ICA.2C_ASR.2C_and_CleanLine.29.2809.2F23.2F2019_updated.29) On of the other things that it helps with is solving artifacts created by sweaty participants.  
When looking at early components, one can usually use a 1Hz filter. This filter might however cause issues if you look at later components (starting at P2 and onwards). 
This is what a 1 Hz filter does
![1hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-1hz.jpg "1Hz_hit")
It's intresting to point out that the inpact of the filter is gets stronger the later you look at the ERP. Since we are interested in the P1 (90-130ms) which is early, we can use this filter. The impact is not big enough to say that it distorts the data.
![fa1hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Fa-FCz-downs-1hz.jpg "1Hz_fa")
In the first figure, we were intressted in the first component, whereas in the second figure we were interested in the error-related positivity (Pe), that is around  200-400ms. Here the filter causes a pretty big difference. For us to use this data, we need to use a lower highpass filter.
##### coming soon, 0.1Hz filter, filter orders

### C_manual_check
This script was added on 5/7/2021, before that this was done, but not through the use of a script. It was completely ran in the EEGlab GUI. 

In this script each subjects data gets loaded and plotted in the EEGlab GUI.

In the GUI set the scale to 5, so you can see if there are flat channels

(example)

![flat channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/flat%20channel.PNG "flat channel")
After that Change the scale to 50 (it is important to always set it to the same scale, so you are sure if data is noisy and not just in a lower scale)

![Noisy channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/very%20noisy.PNG "noisy channel")

When looking at 160 channel data, be sure to check in settings how many channels you want to see. Because it is clear that there are bad channels, but their label is hard to spot.

![160 channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/160-badchan.PNG "160 noisy channel")

After figuring out what channels to delete, type their labels in the command window of Matlab. They need to be entered in the following structure: 

```matlab
{'FC1' 'P1' 'po3'}
```

**Be critical, but if you delete too much (10+ channels) you should think about not using the participant at all.**


### D_avgref_ica_autoexcom
In this script the data gets an referenced to the average to prepare the data for Inter Component Analysis (ICA). 
We are using the pop_runica function for the ICA because it works great as an ICA, but there are other options that might be quicker (this might come at a cost). We do an ICA mainly to delete artifacts that are repeated, such as eye blinks, eye movement, muscle movement and electrical noise.
We are using [IClable](https://www.sciencedirect.com/science/article/pii/S1053811919304185) as a function to automatically label the components. After that it looks what the percentage of "Bad components" are in each individual component. Then it sums the percentage of all of the flagged components and if there is over 80% noise and less then 5% brain a component gets deleted. 

The following components get will get flagged:

- Muscle components
  
- Eye components
  
- Heart components
  
- Line Noise components
  
- Channel noise components

Before deleting the components, EEGlab will save a figure with all the bad components for that participant, or if they were all good, a figure with all the components.
Lastly, Matlab will save a variable called components, with the ID and how many of each type of component reached the threshold. (80% and less then 5% brain, unless it's brain then it's just 80% brain)

These are the variables you NEED to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
home_path  = 'the main folder where you store all the data';

```

These you can change if you want to change settings
```matlab
EEG = pop_runica(EEG, 'extended',1,'interupt','on'); % you can choose a different ICA function, or command it out if you don't want to use it (you will also need to command out the IClable part)
ICA_components(:,8) = sum(ICA_components(:,[2 3 4 5 6]),2); % you can choose different components to be deleted.
bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.05);% how much brain data is too much
```
#### Coming soon, impact of filters on ICA, impact of ICA on simple ERPs

### E_interpolate
This script interpolates all the channels that got deleted before. It does this using the pop_interp function. It loads first the _exext.set file (that was created in B script) to see how many channels there were originally. Then loads the new _excom.set file  and uses the pop_interp to do a spherical interpolation for all channels that were rejected. 

**It is important to realize that if too many channels from around the same location are rejected, the newly formed channels have bad data.** 

For each participant data gets stored containing the ID number and how many channels were interpolated. 

These are the variables you NEED to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
name_paradigm = 'name' % this is how the .mat file with the info is being called
home_path  = 'the main folder where you store all the data';
```

These you can change if you want to change settings
```matlab
EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');% 
```

### F_epoching
This is the last file for pre-processing the data. In this script the interpolated data gets epoched cleaned and turned into an ERP. Some of these functions are ERPlab based. 

Firstly, the data needs to have their events (or triggers) to be updated. You need to create a text file that assigns this info. There are 2 ways of doing this you can define all trials using an eventlist. This is more restrictive, because it seems like you cannot add a sequence of trigger, only individual ones [See this tutorial for more info.](https://github.com/lucklab/erplab/wiki/Creating-an-EventList:-ERPLAB-Functions:-Tutorial).
Instead we use the Binlist option. You can create as many bins as you want. Each bin will create a different ERP, and if you want to use ERP lab to plot ERPs you can choose which ones to plot. If you want to use another program it might be worth it to just save the ERPs of 1 specific bin and run the script multiple times. [see this for information on how to create a binlist.txt file](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/binlist.PNG), or [see this tutorial](https://github.com/lucklab/erplab/wiki/ERP-Bin-Operations)


After that you set the time for the epoch. This is pre-defined in the variable epoch_time and baseline_time  at the start. 
After that we use the pop_artmwppth function to flag all the epochs that are too noisy.
We save this info, after which we delete them. 
**bug**  
For now you need to create at least 2 bins, or ERPlab breaks when you want to average the ERPs. When plotting you can always choose not to use one of the two bins. Later on in the F_individual_trials_export script you can choose to only include the bin you want to (or mutlipe if that is what you want)
**bug** 
Lastly we create the ERPs and save the data as a final .set file.
You will also have a file at the end with each participants ID number and the percentage of data that got deleted. 

You can choose to use the pop_binlister function (see line 35). 

If you end up wanting Reaction time for the ERPs. consider including the [pop_rt2text](https://github.com/lucklab/erplab/blob/master/pop_functions/pop_rt2text.m) function. For this to work you need to define your reaction in the eventlist.  

These are the variables you NEED to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
name_paradigm = 'name'; % this is needed for saving the table at the end
participant_info_temp = []; % needed for creating matrix at the end
home_path  = 'the main folder where you store your data\';
eventlist_location = 'the folder where you stored your eventlist\'; %event list should be named event.txt
epoch_time = [-50 400]; %epoch start and end time in ms
baseline_time = [-50 0];%baseline start and end time in ms
```

These you can change if you want to change settings
```matlab
EEG = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');% 
```

### F_individual_trials_export
If you want to do stats in R or any program that doesn't read .mat files. you need to export your data. This happens in the F script. [For detailed info see its own repo](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab). 

## Statistics

### Loading and setting up the structure
If you open the stats file in Rstudio, you can calculate the statistics in R.
The script does the following, first importing data from .txt file.
After that it creates factors. This is so that everything is in the format for R.
Randomly selects 200 trials per subject (so everyone has equal amounts of data)

### Statistics (including mixed-effects models)
First it creates summary-mean and standard deviation.After that it will plot the data in a violin/box plot. 

you can design your mixed-effects models

after that you can create a summary with the results of the mixed effects model

# Issues
See the [open issues](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues) for a list of proposed features (and known issues).


## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch 
3. Commit your Changes 
4. Push to the Branch 
5. Open a Pull Request

## Updates 
5/7/2021 - adding [C_manual_check script](#c_manual_check) + [biosemi160sfp file](#b_downs_filter_chaninfo_exclextern_exclchan)


## Publications using this pipeline (Only including Papers)
[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., DeMaio, D., & Molholm, S. (2020). Assessing auditory processing endophenotypes associated with Schizophrenia in individuals with 22q11. 2 deletion syndrome. Translational psychiatry, 10(1), 1-11](https://www.nature.com/articles/s41398-020-0764-3)
(unique settings: re-referenced to TP8 and epochs are −100ms to 400ms using a baseline of −100ms to 0ms)

[Francisco, A. A., Horsthuis, D. J., Popiel, M., Foxe, J. J., & Molholm, S. (2020). Atypical response inhibition and error processing in 22q11. 2 Deletion Syndrome and schizophrenia: Towards neuromarkers of disease progression and risk. NeuroImage: Clinical, 27, 102351.](https://www.sciencedirect.com/science/article/pii/S2213158220301881)
(unique settings: 0.1 Hz high pass filter (0.1 Hz transition bandwidth, filter order 16896) and epochs are −100 ms to 1000 using a baseline of −100 ms to 0 ms)

[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., & Molholm, S. (2020). Impaired auditory sensory memory in Cystinosis despite typical sensory processing: A high-density electrical mapping study of the mismatch negativity (MMN). NeuroImage: Clinical, 25, 102170.](https://www.sciencedirect.com/science/article/pii/S2213158220300097)
(unique settings: re-referenced to TP8 and epochs are −100ms to 400ms using a baseline of −100ms to 0ms)

[Francisco, A. A., Berruti, A. S., Kaskel, F. J., Foxe, J. J., & Molholm, S. (2021). Assessing the integrity of auditory processing and sensory memory in adults with cystinosis (CTNS gene mutations). Orphanet Journal of Rare Diseases, 16(1), 1-10.](https://link.springer.com/article/10.1186/s13023-021-01818-0)
(unique settings: re-referenced to TP8 and epochs are −100 to 400ms using a baseline of −50 to 0ms.)

<!-- LICENSE -->

## License

Distributed under the MIT License. See [LICENSE](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/LICENSE) for more information.



<!-- CONTACT -->
## Contact

Douwe John Horsthuis - [@douwejhorsthuis](https://twitter.com/douwejhorsthuis) - douwehorsthuis@gmail.com

Project Link: [https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Ana Francisco](https://github.com/anafrancisco) Who created the basis for this pipeline and took the time to explain everything in detail.
* [Ana Francisco](https://github.com/anafrancisco) Who created and added the statistics part.





[contributors-shield]: https://img.shields.io/github/contributors/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=for-the-badge
[contributors-url]: https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=for-the-badge
[forks-url]: https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/network/members
[stars-shield]: https://img.shields.io/github/stars/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=for-the-badge
[stars-url]: https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/stargazers
[issues-shield]: https://img.shields.io/github/issues/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=for-the-badge
[issues-url]: https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues
[license-shield]: https://img.shields.io/github/license/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=for-the-badge
[license-url]: https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/douwe-horsthuis-725bb9188/




