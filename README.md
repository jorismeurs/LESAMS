# LESAMS
Processing averaged direct MS spectra acquired on an Orbitrap instrument

## System requirement
Windows 10
MATLAB R2017a including the following toolboxes: </br>
- Statistics & Machine Learning Toolbox
- Signal Processing Toolbox
- Bioinformatics Toolbox

## Installation
1. Download the repository as zip file
2. Unpack in the MATLAB folder for storing scripts (in general C:\Users\Username\Documents\MATLAB)
3. Add folder to MATLAB search path

## Initiating class
Type ```obj = LESAMS``` to initiate class. Default values for processing are as follows
```
obj.options.backgroundSubtration = true
obj.options.exportFormat = '.xlsx'
obj.defaultValues.tolerance = 5;
obj.defaultValues.peakHeight = 1e4;
obj.defaultValues.k = 10;
obj.defaultValues.missingValuePercentage = 20;
```

## Functionality
```obj = obj.loadFile``` Retrieve files for processing <br/>
```obj = obj.getPeakList``` Retrieve peak list per file <br/>
```obj = obj.uniqueFeatures``` Get unique features for all sample files <br/>
```obj = obj.retrieveIntensities``` Get the peak intensity per feature per file <br/>
```obj = obj.imputeMissingValues``` Filter out features with a missing value percetange greater than user input and impute remaining values via the *k*nn algorithm <br/>
```obj = obj.removeBackgroundFeatures``` Remove background features from the intensity matrix before export <br/>
```obj.exportData``` Export the intensity matrix in .xlsx format <br/>

## Output
Excel workbook containing the intensity per ion (<it>m/z</it>) for each file (sample). 

## License 
MIT License

## Example data
Data for testing the source is available from https://rdmc.nottingham.ac.uk/handle/internal/6183. The data files consists of LESA-MS data acquired on dried urine sample. Use the files labelled ```UrineStudy_LESAMS_DMA...```. The output Excel file should have 
