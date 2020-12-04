function validateInput(obj)
% Check if conditions are met for processing

if obj.options.backgroundSubtraction ~= true && obj.options.backgroundSubtraction ~= false
   error('Value for background subtraction should be true or false'); 
end

if ~isequal(obj.options.exportFormat,'.xlsx')
   error('Export format should be .xlsx'); 
end

if ~isnumeric(obj.defaultValues.tolerance) || obj.defaultValues.tolerance <= 0
    error('Invalid input for tolerance');
end

if ~isnumeric(obj.defaultValues.peakHeight) || obj.defaultValues.peakHeight < 0
    error('Invalid input for peak height');
end

if ~isnumeric(obj.defaultValues.k) || obj.defaultValues.k < 1 
    error('Invalid input for k');
end

if ~isinteger(obj.defaultValues.k)
   obj.defaultValues.k = uint8(obj.defaultValues.k); 
end

if ~isnumeric(obj.defaultValues.missingValuePercentage) || obj.defaultValues.missingValuePercentage <=0 || obj.defaultValues.missingValuePercentage >= 100
    error('Invalid input for missing value percentage');
end    
    
if isempty(obj.files.spectralFiles)
   disp('Load spectral files first'); 
   return 
end
if obj.options.backgroundSubtraction == true
   if isempty(obj.files.backgroundFile)
      disp('Select a file for background subtraction or disable background subtraction'); 
   end
end

end

