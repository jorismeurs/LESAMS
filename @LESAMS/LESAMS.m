classdef LESAMS
    % Processing averaged LESA-MS data acquired on a Orbitrap system
    
    properties (Constant = true)
        version = '0.1.1';
        developer = 'Joris Meurs, MSc'
        license = 'MIT'
    end
    
    properties
        files
        data
        defaultValues
        options
    end
    
    methods
        function obj = LESAMS()
            source = fileparts(which('LESAMS'));
            source = regexp(source, '.+(?=[@])', 'match'); 
            addpath(source{1});
            
            obj.defaultValues.tolerance = 5;
            obj.defaultValues.peakHeight = 1e4;
            obj.defaultValues.k = 10;
            obj.defaultValues.missingValuePercentage = 20;
            
            obj.files.fileLabels = [];
            obj.files.spectralFiles = [];
            obj.files.backgroundFile = [];
            
            obj.data.backgroundPeaks = [];
            obj.data.peakList = [];
            obj.data.uniqueList = [];
            obj.data.intensityMatrix = [];
            
            obj.options.exportFormat = '.xlsx';
            obj.options.backgroundSubtraction = true;
            obj.options.fileType = [];
        end
        
        function obj = loadFiles(obj)
            [FileName,PathName] = uigetfile({'*.mzXML';'*.txt'},...
                'Load Averaged Spectra',...
                'MultiSelect','on');
            if isequal(FileName,0)
                return
            end
            obj.files.fileLabels = FileName;
            if contains(obj.files.fileLabels,'mzXML')
                obj.options.fileType = 'mzXML';
            elseif contains(obj.files.fileLabels,'txt')
                obj.options.fileType = 'txt';
            else
                error('Invalid file type');
            end
            
            obj.files.spectralFiles = fullfile(PathName,FileName);
            
            if obj.options.backgroundSubtraction == true
               [FileName,PathName] = uigetfile({'*.mzXML';'*.txt'},...
                    'Load Background Spectrum');
                if isequal(FileName,0)
                    return
                end
                obj.files.backgroundFile = fullfile(PathName,FileName); 
            end
        end
        
        function obj = getPeakList(obj)
            validateInput(obj)
            for j = 1:length(obj.files.spectralFiles)
               if isequal(obj.options.fileType,'txt')
                   tempFile = obj.files.spectralFiles{j};
                   averageSpectrum = readSIMSSpectra(tempFile);
               else
                   averageSpectrum  = double(cell2mat(mzxml2peaks(mzxmlread(obj.files.spectralFiles{j}))));
               end
               mz = []; int = [];
               [mz,idx] = unique(averageSpectrum(:,1));
               int = averageSpectrum(idx,2);
               obj.data.peakList{j,1} = mspeaks(mz,int,...
                   'HeightFilter',obj.defaultValues.peakHeight,'Denoising',false);
            end
            if ~isempty(obj.files.backgroundFile)
                if isequal(obj.options.fileType,'txt')
                    tempFile = obj.files.spectralFiles{j};
                    averageSpectrum = readSIMSSpectra(tempFile);
                else
                    backgroundSpectrum = double(cell2mat(mzxml2peaks(mzxmlread(obj.files.backgroundFile))));
                end
                
                obj.data.backgroundPeaks = mspeaks(backgroundSpectrum(:,1),backgroundSpectrum(:,2),...
                    'HeightFilter',obj.defaultValues.peakHeight,'Denoising',false);
            end
        end
        
        function obj = uniqueFeatures(obj)
            validateInput(obj)
            peakVector = cell2mat(obj.data.peakList);
            r = [];
            obj.data.uniqueList = [];
            for j = 1:length(peakVector) 
              if ~isempty(r) 
                 dup = find(r(:,1)==j);
                 if ~isempty(dup) 
                    continue
                 end
              end
              maxDev = ppmDeviation(peakVector(j,1),obj.defaultValues.tolerance);
              matchIons = find(peakVector(:,1) >= peakVector(j,1)-maxDev & ... 
                                peakVector(:,1) <= peakVector(j,1)+maxDev);
              if numel(matchIons) > 1
                  r = [r;matchIons];
                  obj.data.uniqueList = [obj.data.uniqueList;median(peakVector(matchIons,1))];
              else 
                  r = [r;matchIons];
                  obj.data.uniqueList = [obj.data.uniqueList;peakVector(matchIons,1)];
              end
            end
        end
        
        function obj = retrieveIntensities(obj)
            validateInput(obj)
            emptyIDX = find(cellfun(@isempty,obj.data.peakList));
            fileCount = length(obj.files.spectralFiles)-length(emptyIDX);
            obj.data.intensityMatrix = zeros(fileCount,length(obj.data.uniqueList));
            for j = 1:length(obj.data.uniqueList) 
               peakMZ = obj.data.uniqueList(j,1);
               maxDev = ppmDeviation(peakMZ,obj.defaultValues.tolerance);
               for n = 1:length(obj.data.peakList) 
                  if ~isempty(emptyIDX) 
                     if ~isempty(find(emptyIDX(:,1)==n))
                        continue 
                     end
                  end
                  tempData = cell2mat(obj.data.peakList(n,1));
                  peakMatch = find(tempData(:,1) >= peakMZ-maxDev & ... 
                                   tempData(:,1) <= peakMZ+maxDev);
                  if ~isempty(peakMatch) 
                     obj.data.intensityMatrix(n,j) = tempData(peakMatch(1),2);
                  end
               end 
            end 
        end
        
        function obj = imputeMissingValues(obj)
            validateInput(obj)
            c = [];
            for j = 1:size(obj.data.intensityMatrix,2)
               zeroCount = numel(find(obj.data.intensityMatrix(:,j)==0));
               if zeroCount > ceil((obj.defaultValues.missingValuePercentage/100)*size(obj.data.intensityMatrix,1))
                   c = [c,j];
               end
            end
            obj.data.intensityMatrix(:,c) = [];
            obj.data.uniqueList(c,:) = [];

            obj.data.intensityMatrix(obj.data.intensityMatrix==0) = NaN;
            obj.data.intensityMatrix = obj.data.intensityMatrix';
            obj.data.intensityMatrix = knnimpute(obj.data.intensityMatrix,obj.defaultValues.k);
            obj.data.intensityMatrix = obj.data.intensityMatrix';           
        end
        
        function obj = removeBackgroundFeatures(obj)
            validateInput(obj)
            r = [];
            for j = 1:length(obj.data.uniqueList)
                maxDev = ppmDeviation(obj.data.backgroundPeaks(j,1),obj.defaultValues.tolerance);
                matchIon = find(obj.data.uniqueList(:,1) >= obj.data.backgroundPeaks(j,1)-maxDev & ...
                    obj.data.uniqueList(:,1) <= obj.data.backgroundPeaks(j,1)+maxDev);
                if ~isempty(matchIon)
                    r = [r;matchIon];
                end
            end
            obj.data.uniqueList(r,:) = [];
            obj.data.intensityMatrix(:,r) = [];
        end
        
        function exportData(obj)
            validateInput(obj)
            fileName = input('Provide a file name:  ','s');
            try
                xlswrite([fileName obj.options.exportFormat],obj.data.intensityMatrix,'Sheet1','B2');
                xlswrite([fileName obj.options.exportFormat],obj.data.uniqueList','Sheet1','B1');
                xlswrite([fileName obj.options.exportFormat],obj.files.fileLabels','Sheet1','A2');
            catch
                error('File format or file name not supported');
            end
        end
        
        function spectralData = readSIMSSpectra(file)
            fileID = fopen(file,'r'); 
            msData = textscan(fileID,'%f','Delimiter','\t','HeaderLines',3); 
            msData = cell2mat(msData);
            fclose(fileID);
            fclose('all');

            % Reconstruct cell
            mz = msData(2:3:end,1);
            int = msData(3:3:end,1);
            spectralData = [mz,int];
        end
    end
    
end

