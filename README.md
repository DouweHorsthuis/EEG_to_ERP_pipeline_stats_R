EEG pipeline
================
Douwe John Horsthuis
2024-02-14

[![Contributors](https://img.shields.io/github/contributors/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=plastic)](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/graphs/contributors)
[![Forks](https://img.shields.io/github/forks/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=plastic)](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/network/members)
[![Stargazers](https://img.shields.io/github/stars/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=plastic)](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/stargazers)
[![MIT
License](https://img.shields.io/github/license/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R.svg?style=plastic)](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/master/LICENSE.txt)
[![LinkedIn](https://img.shields.io/badge/-LinkedIn-black.svg?style=plastic&logo=linkedin&colorB=555)](https://www.linkedin.com/in/douwe-horsthuis-725bb9188/)

<img src="images/CNL_logo_2.jpeg" alt="Logo" align="center" width="286"/>

# EEG pipeline using EEGlab

This EEG pipeline is made to analyze data collected with a biosemi
system, using however many channels you want. There are several cleaning
steps (e.g. channel rejection, ICA, epoch rejection) after which stats
can be done using R studio. This pipeline contains several scripts,
organized alphabetically. Each script runs a loop on all the
participants, making sure that the same steps are taken for each
participant. The reason it is not one big script is, because after
running each script it would be a good moment to check if you are happy
with the data.

All plots are made using the average data of 38 controls participants
while they are doing a go-no-go task.

**If you have questions or suggestions please reach out to
<douwehorsthuis@gmail.com>**

1.  [About the project](#about-the-project)
    - [Built With](#built-with)
    - [Visual representation of the
      pipeline](#visual-representation-of-the-pipeline)
    - [Publications](#used-for)
2.  [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Usage](#usage)
3.  [Pipeline extended](#pipeline-extended)
    - [Pre-processing](#pre-processing)
      - [A_merge_sets(Matlab)](#a_merge_sets)
      - [Ba_cleaning_optional](#ba_cleaning_optional)
      - [Bb_downs_filter_chaninfo_exclchan(Matlab)](#bb_downs_filter_chaninfo_exclchan)
        - [Filtering](#filtering)
      - [C_manual_check(Matlab)](#c_manual_check)
      - [D_reref_exclextrn_interp_avgref_ica_autoexcom(Matlab)](#d_reref_exclextrn_interp_avgref_ica_autoexcom)
      - [E_epoching(Matlab)](#e_epoching)
      - [F_RT(Matlab)](#f_rt)
    - [Visualizing](#visualizing)
      - [G_building_dashboard_group(Matlab)](#g_building_dashboard_group)
      - [H_grandmeans(Matlab)](#h_grandmeans)
    - [exporting](#exporting)
      - [I_individual_trials_export(Matlab)](#i_individual_trials_export)
    - [Statistics](#statistics)
      - [Loading and setting up the
        structure(Rstudio)](#loading-and-setting-up-the-structure)
      - [Statistics (including mixed-effects
        models)(Rstudio)](#statistics-including-mixed-effects-models)
4.  [Contributing](#contributing)
5.  [Updates](#updates)
6.  [License](#license)
7.  [Contact](#contact)
8.  [Acknowledgements](#acknowledgements)
