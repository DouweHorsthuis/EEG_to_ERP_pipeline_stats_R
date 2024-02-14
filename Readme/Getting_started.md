## Getting Started

To get a local copy up and running follow these steps. [Back to
top](#eeg-pipeline-using-eeglab)

### Prerequisites

Software: You need to have a copy of
[EEGlab](https://sccn.ucsd.edu/eeglab/download.php) (these scripts works
for version eeglab2019_1)

You need to install the [ERPlab](https://erpinfo.org/erplab) plugin.
(these scripts work with erplab8.01)

[Back to top](#eeg-pipeline-using-eeglab)

### Installation

Download a copy of [EEGlab](https://sccn.ucsd.edu/eeglab/download.php).

To install the ERPlab, either download it from
[Github](https://github.com/lucklab/erplab/releases) and save it in the
“Plugins” folder in EEGlab, or open EEGlab and download it via
File–\>Manage EEGLAB extension and look for ERPlab.

[Back to top](#eeg-pipeline-using-eeglab)

<!-- USAGE EXAMPLES -->

### Usage

To use EEGlab you need to set the path to include this folder and all
its sub folders:

[In matlab, set path –\> add with Subfolders… –\>the main eeglab folder
–\>
close](https://github.com/DouweHorsthuis/trial_by_trial_data_export_eeglab/blob/main/images/screenshot_add_path.PNG)
Or you can hard code this:

``` matlab
addpath(genpath('theplacewhereyouhavethefolder\eeglab2019_1\'));
```

[Back to top](#eeg-pipeline-using-eeglab)
next button