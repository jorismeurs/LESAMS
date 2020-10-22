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

## Preparing the data
1. Create an average spectrum in XCalibur for the range of interest
2. Export the spectrum as .RAW file
3. Convert the .RAW to .mzXML in ProteoWizard (no filter, no compression, 32-bit; see example below; msconvert screen can look different depending on version)
![msconvert screen](/images/ProteoWizard.png)

## Initiating class
Type ```obj = LESAMS``` to initiate class. Default values for processing are as follows

### Background subtraction
```obj.options.backgroundSubtration = true``` </br>
Valid input: ```true``` or ```false``` </br>

### Data export format
```obj.options.exportFormat = '.xlsx'``` </br>
Valid input: ```.xlsx``` </br>

### Ion m/z tolerance
M/z tolerance for peak aligment in parts per million (ppm) </br>
```obj.defaultValues.tolerance = 5;``` </br>
Valid input: > 0

### Peak picking
Setting for inclusion peaks above a defined intensity </br>
```obj.defaultValues.peakHeight = 1e4;``` </br>
Valid input: >= 0 </br>

### Missing value imputation
Replacing zeros using the k-nearest neighbour imputation algorithm </br>
Allowed percentage of missing values per ion. Ions with a higher percentage of zero values are removed </br>
``obj.defaultValues.missingValuePercentage = 20;`` </br>
Valid input: >= 0 </br>
</br>

The number of neighbouring values to calculate the weighted average for imputation </br>
```obj.defaultValues.k = 10;```</br>
Valid input: >= 1 </br>


## Functionality
Execute the following lines in the command window in succesion </br>
```obj = obj.loadFile``` Retrieve files for processing <br/>
Number of files required: > 1 </br>
</br>
```obj = obj.getPeakList``` Retrieve peak list per file <br/>
</br>
```obj = obj.uniqueFeatures``` Get unique features for all sample files <br/>
</br>
```obj = obj.retrieveIntensities``` Get the peak intensity per feature per file <br/>
</br>
```obj = obj.imputeMissingValues``` Filter out features with a missing value percetange greater than user input and impute remaining values via the *k*nn algorithm <br/>
</br>
```obj = obj.removeBackgroundFeatures``` Remove background features from the intensity matrix before export <br/>
</br>
```obj.exportData``` Export the intensity matrix in .xlsx format <br/>

## Output
Excel workbook containing the intensity per ion (<it>m/z</it>) for each file (sample). 

## License 
MIT License

## Example data
Data for testing the source is available from https://rdmc.nottingham.ac.uk/handle/internal/6183. The data files (36.53 MB) consists of LESA-MS data acquired (.mzXML) on dried urine sample. Use the files labelled ```UrineStudy_LESAMS_DMA...```. The output Excel file should have 9 rows and 131 columns when using the default values.
