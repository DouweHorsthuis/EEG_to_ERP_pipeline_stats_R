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
    This EEG pipeline is made to analyze data collected with a biosemi system, using however many channels you want. There are several cleaning steps (e.g. channel rejection, ICA, epoch rejection) after which stats can be done using R studio. This pipeline contains several scripts, organized alphabetically. Each script runs a loop on all the participants, making sure that the same steps are taken for each participant. The reason it is not one big script is, because after running each script it would be a good moment to check if you are happy with the data.  
 <br />      
  <br />  
All plots are made using the average data of 38 controls participants while they are doing a go-no-go task.
  <br />   
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
3. [Pipeline order](#pipeline-order)
3. [Pipeline extended](#pipeline-extended)
    - [Pre-processing](#pre-processing)
      - [A_merge_sets(Matlab)](#a_merge_sets)
      - [B_downs_filter_chaninfo_exclchan(Matlab)](#b_downs_filter_chaninfo_exclchan)
        - [Filtering](#filtering)
      - [C_manual_check(Matlab)](#c_manual_check)
      - [D_reref_exclextrn_interp_avgref_ica_autoexcom(Matlab)](#d_reref_exclextrn_interp_avgref_ica_autoexcom)
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

[Back to top](#eeg-pipeline-using-eeglab)  

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these steps.
[Back to top](#eeg-pipeline-using-eeglab)  

### Prerequisites
Software: You need to have a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php) (these scripts works for version eeglab2019_1)

You need to install the [ERPlab](https://erpinfo.org/erplab) plugin. (these scripts work with erplab8.01)
[Back to top](#eeg-pipeline-using-eeglab)  

### Installation
Download a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php). 

To install the ERPlab, either download it from [Github](https://github.com/lucklab/erplab/releases) and save it in the "Plugins" folder in EEGlab, or open EEGlab and download it via File-->Manage EEGLAB extension and look for ERPlab.

[Back to top](#eeg-pipeline-using-eeglab)  

<!-- USAGE EXAMPLES -->
### Usage
To use EEGlab you need to set the path to include this folder and all its sub folders:

[In matlab, set path --> add with Subfolders... -->the main eeglab folder --> close](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab/blob/main/images/screenshot_add_path.PNG)
Or you can hard code this: 

```matlab
addpath(genpath('theplacewhereyouhavethefolder\eeglab2019_1\'));
```  
[Back to top](#eeg-pipeline-using-eeglab)  

## Pipeline order  
  
Here we describe the order of the scripts. The order is obvious sometimes (for example there is no way to do anything without the first script), but less so in other moments (for example, when do you interpolate channels). For more in-dept explanations see [Pipeline extended](#pipeline-extended), or click on the step you want to know more about. 
  
#### [merging and creating a set extention](#a_merge_sets)
#### [Downsampling](#downsampling)
#### [Filtering](#filtering)
#### [Adding channel info](#adding_channel_info)
#### [Deleting channels automatic](#deleting_channels) & [Deleting channels manual](#c_manual_check) 
#### [re-referencing (optional)](#re-referencing)
#### [Interpolation](#interpolate)
#### [average refererence](#average_ R_reference) 
#### [PCA](#pca)
#### [ICA](#ica)
#### [Delete bad components IC](#iclabel)
#### [Epoching](#f_epoching)


[Back to top](#eeg-pipeline-using-eeglab)  

## Pipeline extended
Here you'll see what each script does and what variables you can change.

## Pre-processing

### A_merge_sets
In this script EEGlab will look for all the .bdf or .edf files for all the IDs you enter. Even if you only have one file per participant, you need to run them through this script, because you end up with .set files that have the EEGlab structure in them.
Besides, defining the home/save path, you can choose how many blocks (or .BDF files) your participants have. Normally everyone does the same amount of blocks so this would be the same for everyone, but if not, you need to run that participant separately. 

We used to re-reference the data here (to the mastoids most of the time), but after realizing that it's impossible to spot flat channels after this we pushed this to later in the script.

These are the variables to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
filename= 'the_rest_of_the_file_name';  
home_path  = 'path_where_to_load_in_pc'; 
save_path  = 'path_where_to_save_in_pc'; 
blocks = 5; 
```
[Back to top](#eeg-pipeline-using-eeglab)    
### B_downs_filter_chaninfo_exclchan
#### Downsampling
This script starts by loading the previously created .set file, so you need to set the home_path to where you saved the data and the new data will also be saved there. 
The first thing the script does is down-sample to 256 Hz. We collect data at 512Hz, and there is no real reason to keep it at this high resolution, but it does take up more space and slows down the process when analyzing. 

#### Filtering
The second step is a 1Hz high-pass filter. To change this you need to also decide on the filter order. [See this for more info](https://github.com/widmann/firfilt/blob/master/pop_eegfiltnew.m)

Same counts for the third step, which is a 45Hz high-pass filter. For more detailed info on filters see the ["More info on filtering " chapter](#more_info_on_filtering).

To optimize the ICA solutions, these are the suggested filters. However, if you want to look at components that show up later in the data, 1Hz might be too high. [See this paper for more info on filters.](https://www.sciencedirect.com/science/article/pii/S0896627319301746)

#### Adding channel info
The fourth step is adding information to the channels. This is why you need to define the path to EEGlab or to the 'biosemi160' file. It will look for a file to import the channel information. The difference between the two paths has to do with that for 64channels we use a 10-20 layout for the BIOsemi caps, however for the 160channel caps we have a spherical layout. The first file is part of EEGlab, but this is not the case for the 160channel cap. 64channels is defined as 64 to 95, because a full extra ribbon would be 96 channels. In or lab we normally go up to 8 channels, but we have data that has more. This takes that in consideration. 

#### Deleting channels
Lastly, in step 5, it will reject channels based on a kurtosis threshold. It is set to 5, which is the standard. Channels with a kurtosis > 5 will be deleted.


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
EEG = pop_rejchan(EEG,'elec', [1:64],'threshold',5,'norm','on','measure','kurt'); %the rejection threshold (standard is 5), [1:64 or 1:160 because you don't want to include the externals]
```  
[Back to top](#eeg-pipeline-using-eeglab)  

#### More info on filtering 
You do not need to follow the filtering in this script. EEGlab makes it relatively easy to created/use new filters. 

##### Using a new filter in EEGlab
If you want to change your filter the easiest way, you open a random .set file. and do the following 3 steps:  

![step1](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Open_filter.PNG "open")  
![step2](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/filter%20inputs.PNG "input")  
Here you input the Filter you want. To create a 1Hz filter, you input the number 1 in the "lower edge of the frequency pass band (Hz)" box and hit "ok"  
![step3](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/figure%20out%20filter%20order.PNG "output")  
This shows up in Matlab. Replace the filter number with the number 1. followed by the number "preforming [number] point high-pass filter" -1 as the filter order. 

```matlab
EEG = pop_eegfiltnew(EEG, [],0.01,168960,1,[],1); %this 0.01hz filter changes like this: 
EEG = pop_eegfiltnew(EEG, [],1,1690,0,[],1); %into a 1 hz filter
```

##### What filter should I choose
Choosing what filters to use will have a big impact on your data. There are a couple things to consider because filters will have impact in several different ways on your data. 

**ICA** The [EEGlab people](https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline#High-pass_filter_the_data_at_1-Hz_.28for_ICA.2C_ASR.2C_and_CleanLine.29.2809.2F23.2F2019_updated.29) suggest using a 1Hz and 45Hz filter to get the best ICA solutions. But if one only uses the ICA for removing eye blinks and eye movement it might be worth it to think this through.
###### Low-pass filter 
We usually use a low-pass filter to get rid of high frequency noise that cannot be caused by the brain. By using a 45Hz filter this can be solved.Unless you are interested in specific frequencies that go above 40Hz it's normally safe to use it. 
This is what the filter will do to data:  
![45hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-45hz.jpg "45Hz")  
The black line is down-sampled like the Red line + a 45Hz filter is ran on it. If you look at the zoomed in parts it is clear the this smooths out the ERP. 
###### High-pass filter
A high-pass filter is used to stop Baseline drift. [This drift is stronger for kids and some patient populations (0.1Hz) then for Adult subjects (0.01Hz).](https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline#High-pass_filter_the_data_at_1-Hz_.28for_ICA.2C_ASR.2C_and_CleanLine.29.2809.2F23.2F2019_updated.29) One other thing it helps with is solving artifacts created by sweat.  
When looking at early components, one can usually use a 1Hz filter. This filter might however cause issues if you look at later components (starting at P2 and onward). 
This is what a 1 Hz filter does
![1hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-1hz.jpg "1Hz_hit")
It's interesting to point out that the impact of the filter is more strongly seen the later you look at the ERP. Since we are interested in the P1 (90-130ms) which is early, we can use this filter. The impact is not big enough to say that it distorts the data.
![fa1hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Fa-FCz-downs-1hz.jpg "1Hz_fa")
In the first figure, we were interested in the first component, whereas in the second figure we were interested in the error-related positivity (Pe), that is around  200-400ms. Here the filter causes a pretty big difference. For us to use these data, we need to use a lower high-pass filter.

##### comparing different filters
It is very important that you know what the impact of your filter can be. One of the things to think of is what frequency you expect in the ERP. If it's in the higher Range you could go for a 0.5Hz or maybe a 1Hz filter (1Hz might be too much according to some).
![1-01-001hzfilters](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-1-01-001hz.jpg)
As you can see here, the filters seem to have more or less the same impact, since we are looking at the early components.  
However here we want to look at later components and we are looking at a ERP based on a False alarm which should be a lower frequency response.
![001-01-1hzfilters](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Fa-FCz-downs-1-01-001hz.jpg)  
Here the 1Hz filter has way too much effect and distorts the data. 

##### comparing different filter orders
In the following 2 plots we ran the same 1Hz filter on the data, but we changed the filter order. The standard filter order suggested by EEGlab for a 1Hz filter is 1690 (this order is different for different filters; a 0.1Hz filter has a suggested order of 16895). We chose 846 as filter order because this is the smallest filter order that can be chosen for this filter. If you would choose a different filter the minimum is different. There is no max filter order, but when we tested 100000000 as an order, after 2 days EEGlab hadn't completed 5%.  

![hit-filteroder](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/filterorder_hit.jpg)
![fa-filteroder](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/filterorder_fa.jpg)  

##### Final product
This is the combination of a 1Hz and a 45Hz filter
![1hz_45hzfilter](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/Hit-Po7-downs-1%2645hz.jpg "1Hz_45Hz")

[Back to top](#eeg-pipeline-using-eeglab)  


### C_manual_check
 
In this script each subject's data gets loaded, externals get deleted and the data gets plotted in the EEGlab GUI.

In the GUI set the scale to 5, so you can see if there are flat channels

(example)

![flat channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/flat%20channel.PNG "flat channel")
After that Change the scale to 50 (this value will be automatically set and different for each data set). It is important to always set it to the same scale, so that you can compare noise between data sets.

![Noisy channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/very%20noisy.PNG "noisy channel")

When looking at 160 channel data, be sure to check in settings how many channels you want to see. Because it is clear that there are bad channels, but their label is hard to spot.

![160 channels](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/160-badchan.PNG "160 noisy channel")

After figuring out which channels to delete, type their labels in the command window of Matlab. They need to be entered in the following structure: 

```matlab
{'FC1' 'P1' 'po3'}
```

**Be critical, but if you delete too many channels (>10) you should consider whether that data set should be included.**

[Back to top](#eeg-pipeline-using-eeglab)  

### D_reref_exclextrn_interp_avgref_ica_autoexcom

#### re-referencing
After realizing that re-referencing causes flat channels to have the data of the reference channel and thus making it impossible to see if it's flat, we only re-reference here (after having deleted all the channels that are noisy/flat).  
You can choose a reference channel. [Biosemi explains why it matters for their system](https://www.biosemi.com/faq/cms&drl.htm) but that you should [delete flat channels first](https://www.biosemi.nl/forum/viewtopic.php?f=7&t=810&p=3871#p3871). [Brainproducts](https://pressrelease.brainproducts.com/referencing/) and [this paper](https://www.frontiersin.org/articles/10.3389/fnins.2017.00205/full) Also agree that mastoids are commonly used and good, the paper also talks about different options that could work. 

In our case we use the average of both mastoids (channel 65/66 for us), but you can change this to a different channel or leave it empty if you don't want to do this.

This is the impact it has on our data. Here we compare data referenced to the mastoid externals with data where we left the ref_chan variable empty.  
![hit-ref](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/hit-po7-ext-noext.jpg "hit-ref")  
![fa-ref](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/fa-fcz-ext-noext.jpg "fa-ref")  
The first plot is the ERP after a Hit. The second one is after a False alarm. It is clear that the amplitudes increase significantly, however it does seem like the standard error also increases. 

#### Interpolate

After that we re-referencing we interpolate. We moved this up from where it was before (after the ICA), because this allows us to use the ICA weights and gives us all the channels. 

Here we interpolates all the channels that got deleted before. It does this using the pop_interp function. It loads first the _info.set file (that was created in B script) to see how many channels there were originally (it deletes the externals because you don't want these in your new data). Then we use the pop_interp to do a spherical interpolation for all channels that were rejected. 

**It is important to realize that if too many channels from around the same location are rejected, the newly formed channels have inaccurate data.** 

For each participant, data get stored containing the ID number and how many channels were interpolated. 

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
[Back to top](#eeg-pipeline-using-eeglab)  

#### Average Reference
After this we reference the data to the average, in preparation for Independent Component Analysis (ICA). 

### PCA
The PCA is set to the amount of channels deleted -1 (for the average reference), the PCA will dictate how many components the ICA will create. This is especially important because we are interpolating and doing an average reference before the ICA. This could cause "ghost components", or just make the data go bad all together due to working with data that is rank deficiant. Setting the PCA preferents this rank issue. Another solution is to delete a channel (after the average ref). But this would still not solve the issue for the interpolated channels + we would lose a good channel.

### ICA
We are using the pop_runica function, as suggested by EEGLab, but there are other options that might be quicker (this might, however, come at a cost). We do an ICA mainly to delete artifacts that are repeated, such as eye blinks, eye movement, muscle movement and electrical noise.  
   
### IClabel
We are using [IClable](https://www.sciencedirect.com/science/article/pii/S1053811919304185) as a function to automatically label the components. After that, we only delete the eye-components. We only focus on eye-blinks because we know they have a bad/strong impact on the data and as you can see in [the next part](#impact-of-ica-on-simple-erps) deleting more has a very strong impact on the data and we are not sure what gets deleted. In our case components will only get deleted if they are >80% eye and <10% brain. We decided on these criteria after comparing how many components experts in our lab would delete and what criteria would match this the closesed.

Matlab will save a figure with the deleted Eye components and with all the remaining components grouped separately.
Lastly, Matlab will save a variable called components, with the ID and how many of each type of component reached the threshold. 

These are the variables you NEED to change:
```matlab
subject_list = {'some sort of ID' 'a different id for a different particpant'}; 
home_path  = 'the main folder where you store all the data';

```

These you can change if you want to change settings
```matlab
EEG = pop_runica(EEG, 'extended',1,'interupt','on'); % you can choose a different ICA function, or command it out if you don't want to use it (you will also need to command out the IClable part)
bad_components = find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05);% look for >80% eye and <5% brain
```

#### Impact of ICA on simple ERPs
This is an example of what the ICA does to an ERP. 
![ERP-ICA-vs-no-ICA](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/filtering/1%2645-withandwithout-ica.jpg)  

Here you see the impact of the ICA on data after using IClabel to auto delete bad components. While all of the components that are deleted are non-brain related and we even check that within the components there is less than 5% brain data, the impact is huge. When using ICA always make sure to use the right setting and make sure your data look the way it should. Doing it manually takes a lot of practice and understanding of the data and a lot of time. This is why we currently prefer the more objective [IClabel](https://github.com/sccn/ICLabel) function in EEGlab  

To make more sense of the impact of deleting components I've plotted 4 different ERPs. 
  - For the first ERP I deleted for each participant every component if the labels* of the sum of bad** components >90 and the brain label <3%***
  - For the second ERP I only deleted a component if the eye label would be >80% and the brain label <5% 
  - For the third ERP I deleted for each participant every component if the labels of the sum of bad components >80 and the brain label <5%
  - For the fourth ERP I did not delete any component, this is the ERP before IClabel is ran.

The first plot is an VEP directly after seeing a stimulus  
![ERP-ICA-vs-no-ICA-hit](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/iclabledifferences_hit.jpg)  
The second plot is an ERP after a False Alarm (button press when they were supposed to inhibit)
![ERP-ICA-vs-no-ICA-fa](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/iclabledifferences_fa.jpg) 

\* IClabel labels for each component how much % they are made up out of [Brain, muscle, eye, Heart, Line Noise, channel noise and other]  
\** We only use a sum of muscle, eye, Heart, Line Noise, channel noise to create bad components  
\*** every label will always have something above 0%, this is why I didn't want to go lower then 3%  



### F_epoching
This is the last file for pre-processing the data. In this script the interpolated data get epoched, cleaned, and transformed into an ERP. Some of these functions are ERPlab based. 

Firstly, the data needs to have their events (or triggers) to be updated. You need to create a text file that assigns this info. There are 2 ways of doing this.  
You can define all trials using an eventlist. This is more restrictive, because it seems like you cannot add a sequence of triggers, only individual ones [See this tutorial for more info.](https://github.com/lucklab/erplab/wiki/Creating-an-EventList:-ERPLAB-Functions:-Tutorial).  
Instead, we use the Binlist option. You can create as many bins as needed. Each bin will create a different ERP, and if you want to use ERPlab to plot ERPs you can choose which ones to plot. If you want to use another program it might be worth it to just save the ERPs of 1 specific bin and run the script multiple times. [see this for information on how to create a binlist.txt file](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/binlist.PNG), or [see this tutorial](https://github.com/lucklab/erplab/wiki/ERP-Bin-Operations)


After that you set the time for the epoch. This is pre-defined in the variable epoch_time and baseline_time  at the start. 
After that we use the pop_artmwppth function to flag all the epochs that are too noisy.
We save this info, after which we delete them.  
**bug when using EEGlab V2019_1**  
You need to create at least 2 bins, or ERPlab breaks when you want to average the ERPs. When plotting you can always choose not to use one of the two bins. Later on in the F_individual_trials_export script you can choose to only include the bin you want to (or multiple if that is what you want).
This is not the case if you use EEGlab V2021.1
**bug when using EEGlab V2019_1** 
Lastly we create the ERPs and save the data as a final .set file.
You will also have a file at the end with each participant's ID number and the percentage of data that got deleted. 

You can choose to use the pop_binlister function (see line 35). 

If you end up wanting Reaction time for the ERPs, consider including the [pop_rt2text](https://github.com/lucklab/erplab/blob/master/pop_functions/pop_rt2text.m) function. For this to work you need to define the event that reflects the reaction you want to measure in the eventlist.  

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
[Back to top](#eeg-pipeline-using-eeglab)  

### F_individual_trials_export
If you want to do stats in R or any program that doesn't read .mat files, you need to export your data. This happens in the F script. [For detailed info see its own repo](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab). 

## Statistics

### Loading and setting up the structure
Here we compute statistics using R and Rstudio.
The script does the following. It imports data from .txt file, it creates factors and it randomly selects 200 trials per subject (so everyone has equal amounts of data)

### Statistics (including mixed-effects models)
First it creates a summary of the data, which includes mean and standard deviation.
After that it plots the data in a violin/box plot. 

You can design your mixed-effects model and, after that, create a summary with the results of your model computation.

[Back to top](#eeg-pipeline-using-eeglab)  

# Issues
See the [open issues](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues) for a list of proposed features (and known issues).


## Contributing

Please contact me if you see anything in this pipeline that you think could be improved. I'm always looking to improve the pipeline!  
[Back to top](#eeg-pipeline-using-eeglab)  


## Updates 
5/7/2021 - adding [C_manual_check script](#C_manual_check) + [biosemi160sfp file](#B_downs_filter_chaninfo_exclchan)  
6/17/2021- updating the re-referencing situation. We used to do this in the first script when loading the BDF file, but this caused problems with flat channels not being flat anymore.  
6/17/2021- updating [D_reref_exclextrn_avgref_ica_autoexcom](#D_reref_exclextrn_avgref_ica_autoexcom), only deleting eye-components from now on. 

[Back to top](#eeg-pipeline-using-eeglab)  


## Publications using this pipeline (Only including Papers)
[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., DeMaio, D., & Molholm, S. (2020). Assessing auditory processing endophenotypes associated with Schizophrenia in individuals with 22q11. 2 deletion syndrome. Translational psychiatry, 10(1), 1-11](https://www.nature.com/articles/s41398-020-0764-3)
(unique settings: re-referenced to TP8 and epochs are −100ms to 400ms using a baseline of −100ms to 0ms)

[Francisco, A. A., Horsthuis, D. J., Popiel, M., Foxe, J. J., & Molholm, S. (2020). Atypical response inhibition and error processing in 22q11. 2 Deletion Syndrome and schizophrenia: Towards neuromarkers of disease progression and risk. NeuroImage: Clinical, 27, 102351.](https://www.sciencedirect.com/science/article/pii/S2213158220301881)
(unique settings: 0.1 Hz high pass filter (0.1 Hz transition bandwidth, filter order 16896) and epochs are −100 ms to 1000 using a baseline of −100 ms to 0 ms)

[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., & Molholm, S. (2020). Impaired auditory sensory memory in Cystinosis despite typical sensory processing: A high-density electrical mapping study of the mismatch negativity (MMN). NeuroImage: Clinical, 25, 102170.](https://www.sciencedirect.com/science/article/pii/S2213158220300097)
(unique settings: re-referenced to TP8 and epochs are −100ms to 400ms using a baseline of −100ms to 0ms)

[Francisco, A. A., Berruti, A. S., Kaskel, F. J., Foxe, J. J., & Molholm, S. (2021). Assessing the integrity of auditory processing and sensory memory in adults with cystinosis (CTNS gene mutations). Orphanet Journal of Rare Diseases, 16(1), 1-10.](https://link.springer.com/article/10.1186/s13023-021-01818-0)
(unique settings: re-referenced to TP8 and epochs are −100 to 400ms using a baseline of −50 to 0ms.)
[Back to top](#eeg-pipeline-using-eeglab)  

<!-- LICENSE -->

## License

Distributed under the MIT License. See [LICENSE](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/LICENSE) for more information.

[Back to top](#eeg-pipeline-using-eeglab)  


<!-- CONTACT -->
## Contact

Douwe John Horsthuis - [@douwejhorsthuis](https://twitter.com/douwejhorsthuis) - douwehorsthuis@gmail.com

Project Link: [https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R)

[Back to top](#eeg-pipeline-using-eeglab)  


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Ana Francisco](https://github.com/anafrancisco) Who created the basis for this pipeline and took the time to explain everything in detail.
* [Ana Francisco](https://github.com/anafrancisco) Who created and added the statistics part.



[Back to top](#eeg-pipeline-using-eeglab)  


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




