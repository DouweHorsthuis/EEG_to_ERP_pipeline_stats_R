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

### Visual representation of the pipeline

<figure>
<img
src="https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R/blob/main/images/Procesflow.png"
alt="cleaning data" />
<figcaption aria-hidden="true">cleaning data</figcaption>
</figure>

### Publications

The following are the papers that we published using this pipeline.

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

[Francisco, A. A., Berruti, A. S., Kaskel, F. J., Foxe, J. J., &
Molholm, S. (2021). Assessing the integrity of auditory processing and
sensory memory in adults with cystinosis (CTNS gene mutations). Orphanet
Journal of Rare Diseases, 16(1),
1-10.](https://link.springer.com/article/10.1186/s13023-021-01818-0)
(unique settings: re-referenced to TP8 and epochs are −100 to 400ms
using a baseline of −50 to 0ms.)

List is not complete

[Back to start](https://github.com/DouweHorsthuis/EEG_to_ERP_pipeline_stats_R?tab=readme-ov-file#eeg-pipeline-using-eeglab)
Add here a next button
