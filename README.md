EEG pipeline
================
Douwe John Horsthuis
2024-02-21

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

## For in dept explanations check the WIKI

[Link to
wiki](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/wiki)

1.  [About the project](#about-the-project)
    - [Built With](#built-with)
    - [Visual representation of the
      pipeline](#visual-representation-of-the-pipeline)
    - [Publications](#used-for)
2.  [Pipeline order](#pipeline-order)
3.  [Contributing](#contributing)
4.  [Updates](#updates)
5.  [License](#license)
6.  [Contact](#contact)
7.  [Acknowledgements](#acknowledgements)

## About The Project

This EEG pipeline is made to analyze data collected with a biosemi
system, using however many channels you want. There are several cleaning
steps (e.g. channel rejection, ICA, epoch rejection) after which stats
can be done using R studio. It is scalable to multiple groups and
variables such as filter strength, and rejection thresholds are
changeable, but are pre-tested and worked for multiple publications.

### Built With

- [Matlab](https://www.mathworks.com/)
- [EEGlab](https://sccn.ucsd.edu/eeglab/index.php)
- [ERPlab](https://github.com/lucklab/erplab) (EEGlab plugin)
- [Rstudio](https://www.rstudio.com/)

[Back to top](#eeg-pipeline-using-eeglab)

### Publications

The following are the papers that we published using this pipeline.

[Horsthuis, D. J., Molholm, S.,Foxe, J. J., & Francisco, A. A.(2023)
Event-related potential (ERP) evidence for visual processing differences
in children and adults with cystinosis (CTNS gene mutations)Orphanet
Journal of Rare Diseases 18 (1),
389](https://link.springer.com/article/10.1186/s13023-023-02985-y)

[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., & Molholm, S. (2022).
Early visual processing and adaptation as markers of disease, not
vulnerability: EEG evidence from 22q11.2 deletion syndrome, a population
at high risk for schizophrenia. Schizophr 8,
28.](https://www.nature.com/articles/s41537-022-00240-0)

[Francisco, A. A., Berruti, A. S., Kaskel, F. J., Foxe, J. J., &
Molholm, S. (2021). Assessing the integrity of auditory processing and
sensory memory in adults with cystinosis (CTNS gene mutations). Orphanet
Journal of Rare Diseases, 16(1),
1-10.](https://link.springer.com/article/10.1186/s13023-021-01818-0)
(unique settings: re-referenced to TP8 and epochs are −100 to 400ms
using a baseline of −50 to 0ms.)

[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., DeMaio, D., & Molholm,
S. (2020). Assessing auditory processing endophenotypes associated with
Schizophrenia in individuals with 22q11. 2 deletion syndrome.
Translational psychiatry, 10(1),
1-11](https://www.nature.com/articles/s41398-020-0764-3) (unique
settings: re-referenced to TP8 and epochs are −100ms to 400ms using a
baseline of −100ms to 0ms)

[Francisco, A. A., Horsthuis, D. J., Popiel, M., Foxe, J. J., & Molholm,
S. (2020). Atypical response inhibition and error processing in 22q11. 2
Deletion Syndrome and schizophrenia: Towards neuromarkers of disease
progression and risk. NeuroImage: Clinical, 27,
102351.](https://www.sciencedirect.com/science/article/pii/S2213158220301881)
(unique settings: 0.1 Hz high pass filter (0.1 Hz transition bandwidth,
filter order 16896) and epochs are −100 ms to 1000 using a baseline of
−100 ms to 0 ms)

[Francisco, A. A., Foxe, J. J., Horsthuis, D. J., & Molholm, S. (2020).
Impaired auditory sensory memory in Cystinosis despite typical sensory
processing: A high-density electrical mapping study of the mismatch
negativity (MMN). NeuroImage: Clinical, 25,
102170.](https://www.sciencedirect.com/science/article/pii/S2213158220300097)
(unique settings: re-referenced to TP8 and epochs are −100ms to 400ms
using a baseline of −100ms to 0ms)

[Back to top](#eeg-pipeline-using-eeglab)

### Visual representation of the pipeline

![](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/Procesflow.png)

[Back to top](#eeg-pipeline-using-eeglab)

## Pipeline order

Here we describe the order of the scripts. The order is obvious
sometimes (for example there is no way to do anything without the first
script), but less so in other moments (for example, when do you
interpolate channels). For more in-dept explanations see [Pipeline
extended](#pipeline-extended), or click on the step you want to know
more about, and you will be send to the wiki page for more info.

[merging and creating a set extention](#a_merge_sets)  
[Cleaning Optional](#cleaning_optional) [Downsampling](#downsampling)  
[Filtering](#filtering)  
[Adding channel info](#adding_channel_info)  
[Deleting channels automatic](#deleting_channels) & [Deleting channels
manual](#c_manual_check)  
[Interpolation](#interpolate)  
[Average reference](#average_reference)  
[PCA](#pca)  
[ICA](#ica)  
[Delete bad components IC](#iclabel) [re-referencing
(optional)](#re-referencing) [Epoching](#f_epoching)

## All explanations are in the process of being moved to the wiki page

[Link to
wiki](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/wiki)

[Back to top](#eeg-pipeline-using-eeglab)

# Issues

See the [open
issues](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/issues)
for a list of proposed features (and known issues).

## Contributing

Please contact me if you see anything in this pipeline that you think
could be improved. I’m always looking to improve the pipeline!  
[Back to top](#eeg-pipeline-using-eeglab)

## Updates

5/7/2021 - adding [C_manual_check script](#C_manual_check) +
[biosemi160sfp file](#B_downs_filter_chaninfo_exclchan)  
6/17/2021- updating the re-referencing situation. We used to do this in
the first script when loading the BDF file, but this caused problems
\<\<\<\<\<\<\< HEAD with flat channels not being flat anymore.  
6/17/2021 - updating  
[D_reref_exclextrn_avgref_ica_autoexcom](#D_reref_exclextrn_avgref_ica_autoexcom),only
deleting eye-components from now on.  
10/17/2022 - Working on a QA dashboard that will show you both
individual subject and group related information to see without hassle
how your data look  
12/20/2022 - Added a script that is optional so that you can see how
much data get’s deleted when you clean your data and what would be the
best settings for your data. 2/14/2024 - major update to get everything
smoothed out. All programs should run without issues. There is a
visualisation step at the end. There is now a reaction time script.

[Back to top](#eeg-pipeline-using-eeglab)

<!-- LICENSE -->

## License

Distributed under the MIT License. See
[LICENSE](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/LICENSE)
for more information.

[Back to top](#eeg-pipeline-using-eeglab)

<!-- CONTACT -->

## Contact

Douwe John Horsthuis -
[@douwejhorsthuis](https://twitter.com/douwejhorsthuis) -
<douwehorsthuis@gmail.com>

Project Link:
<https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R>

[Back to top](#eeg-pipeline-using-eeglab)

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

- [Ana Francisco](https://github.com/anafrancisco) Who created the basis
  for this pipeline and took the time to explain everything in detail.
- [Filip De Sanctis](https://github.com/pdesanctis)
- [Sophie
  Molholm](https://www.einsteinmed.edu/faculty/12028/sophie-molholm/)

[Back to top](#eeg-pipeline-using-eeglab)
