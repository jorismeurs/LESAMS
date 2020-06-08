# LESAMS
Processing averaged LESA-MS spectra acquired with an Orbitrap instrument

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
```obj = obj.loadFile``` Retrieve files for processing
```obj = obj.getPeakList``` Retrieve peak list per file
```obj = obj.uniqueFeatures``` Get unique features for all sample files
```obj = obj.retrieveIntensities``` Get the peak intensity per feature per file
```obj = obj.imputeMissingValues``` Filter out features with a missing value percetange greater than user input and impute remaining values via the _k_nn algorithm
```obj = obj.removeBackgroundFeatures``` Remove background features from the intensity matrix before export
```obj.exportData``` Export the intensity matrix in .xlsx format
