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
    This EEG pipeline is made to analyze data collected with a biosemi system, using however many chanels you want. There are several cleaning steps (e.g. channel rejection, ICA, epoch rejection) after which stats can be done using Rstudio. This pipeline contain several scripts, organized alphabetically. Each script runs a loop on all the particpants, making sure that the same steps are taken for each participant. The reason it is not one big script is, because after running each script it would be a good moment to check if you are happy with the data. 
    <br />
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R"><strong>Explore the docs ?</strong></a>
    <br />
    <br />
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R">View Demo</a>
    ?
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues">EEG_to_ERP_pipeline_stats_Rrt Bug</a>
    ?
    <a href="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#usage">Usage</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#Publications">Publications</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)
This EEG pipeline is made to analyze data collected with a biosemi system, using however many chanels you want. There are several cleaning steps (e.g. channel rejection, ICA, epoch rejection) after which stats can be done using Rstudio. It is scalable to mulitple groups and variables such as filter strenght, and rejection thresholds are changeable, but are pre-tested and worked for mulitple publications.


### Built With

* [Matlab](https://www.mathworks.com/)
* [EEGlab](https://sccn.ucsd.edu/eeglab/index.php)
* [ERPlab](https://github.com/lucklab/erplab) (EEGlab plugin)



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites
Software: You need to have a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php) (these scripts works for version eeglab2019_1)

You need to install the [ERPlab](https://erpinfo.org/erplab) plugin. (these scripts work with erplab8.01)

### Installation
Download a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php). 

To install the ERPlab, either download it from [Github](https://github.com/lucklab/erplab/releases) and save it in the "Plugins" folder in EEGlab, or open EEGlab and download it via File-->Manage EEGLAB extention and look for ERPlab.


<!-- USAGE EXAMPLES -->
### Usage
To use EEGlab you need to set the path to include this folder and all it's subfolders:

[In matlab, set path --> add with Subfolders... -->the main eeglab folder --> close](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab/blob/main/images/screenshot_add_path.PNG)
Or you can hardcode this: 

```matlab
addpath(genpath('theplacewhereyouhavethefolder\eeglab2019_1\'));
```


<!-- ROADMAP -->
## Pipeline roadmap
Here you'll see what each scipt does and what variables you can need to change.

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
The first thing the script does is downsample to 256 hz. We collect data at 512Hz, and there is no real reason to keep it at this high resolution. 

The second step is a 1Hz highpass filter. To change this you need to also decide on the filter order. [See this for more info](https://github.com/widmann/firfilt/blob/master/pop_eegfiltnew.m)

Same counts for the third step, which is a 45hz highpass filter.

To optimize the ICA solutions, these are the suggested filters. Howerver, if you want to look at components that show up later in the data, 1Hz might be too high. [See this paper for more info.](https://www.sciencedirect.com/science/article/pii/S0896627319301746)

# Issues
See the [open issues](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


##Publications

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Your Name - [@douwejhorsthuis](https://twitter.com/douwejhorsthuis) - douwehorsthuis@gmail.com

Project Link: [https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* []()
* []()
* []()





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
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
[linkedin-url]: https://linkedin.com/in/DouweHorsthuis
















# EEG_to_ERP_matlab_stats_R
General pipeline used for analyzing EEG data where Raw EEG data gets transformed into ERPS, stats get done in R-studio

# EEG-Raw-to-ERP (BIOSEMI)
General pipeline used for analyzing EEG data where Raw EEG data gets transformed into ERPS
This pipeline is created and updated between 2017-2021. It uses Matlab and needs the plugin EEGlab and ERPlab to function. 
The pipeline has 5 script that can be run after eachother. 

Script 1 (A_merge_sets) loads the .BDF files potentially merging them if there are multiple per participant and creates individual .set files for next step.

Script 2 (B_downs_filter_chaninfo_exclextern_exclchan) downsamples (256hz) Highpass (filter 1hz) Lowpass filter (45hz), excludes externals, auto channels rejection based on a kurtosis threshold.

Script 3 (C_avgref_ica_autoexcom) This scripts does an average reference, uses runica and IClabel to created IC components and defines and deletes the bad ones. The bad components also get printed. Bad IC components are definde by IClable if they contain more than 80% of a combination of muscle, eye, heart, line noise and channel noise and less than 5% brain.

Script 4 (D_interpolate) it interpolates the channels and creates a file which channels were deleted for which participant.

Script 5 (E_epoching) it epochs the continues data, runs a last cleaning where it deletes all the epochs that are too noisy (this amount gets saved for each participant) saves the data as both .erp and .set.

events.txt this file is used in script 5. it can be created by using ERP lab, but it needs all the triggers from the data that are relevant, assigns a name to them and a bin. (example: 101 "first trigger" 1 "first trigger" 102 "last trigger" 2 "last trigger").

# Stats-R
Calculating Stats in R


importing data from .txt file

Creating Factors

Creates summary-mean and standard deviation

Randomly selects 200 trials per subject (so everyone has equal amounts of data)

plots (violin + boxplot)

mixed-effects models

Summary of mixed effects model


