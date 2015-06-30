clear all;

%% Script for the reconstruction of the APS data
%% Basic configuration - do only change here parameters, if you don't know what you do.

% Path to data
config.path    = '/mnt/LSDF/tomo/APS_32ID-C_2014-07-16_GUP38469/';
config.data    = 'data/';
config.extension  = '.hdf';

% Use file with experiments, projections and cropping area
config.useInputFile  = true;
config.inputFilePath = '';
config.inputFileName = 'datainput';

config.inputPath = '/mnt/LSDF/tomo/APS_32ID-C_2014-07-16_GUP38469/reco_a2/';

% If InputFile is used, these are dynamical. set dynamical
config.folder  = '2014_07_18_18_55_stage19_4_edge_5x_100um_LuAG_60ms_30keV_2vx2.5h_500proj_3DegPerSec_715mm/';
config.name    = 'proj_263';
% --------------------------------------------------------

% Astra
config.makeSino    = true;
config.useAstra    = true;

% Logfile position with 
config.logFilePath = ''; % '/home/ws/uldjt/reco/recoScriptMS/';
config.logFileName = 'log';

% Shall 3D reconstruction be used.
config.use3D = true;

% Shall the darks and flats be recalculated.
config.createMeanDark=true;
config.createMeanFlat=true;


% If InputFile is used, these are dynamical.
config.horizontalstart = 300;
config.horizontalend = 1850;

config.verticalstart = 32;
config.verticalend = 1125;
% ------------------------------------------

%% ------------------------------------------------------------------
% slice depth (2D); depends on number of projections (regular: 500)

config.depth = 800;

% Shifts from 499 : 1 -> 500 : 2 
config.shiftProjnumber = 1;

% fixed for tomo

config.maxAngle=180;

%% Saving setting
% Path of save enviroment
config.savepath = '/mnt/LSDF/tomo/APS_32ID-C_2014-07-16_GUP38469/reco_QP_3/';
config.saveflag = '';

% save mean flat, dark
config.savedark = true;
config.saveflat = true;
config.savecrop = true; % cropped and corrected intensity field of detector
config.savesino = true;
config.savetomo = true;


% TODO:
% - option for partial use (for example: no second calculation of cropped
% dark and flat.
% - slice script in different subscripts.
% - find out if data is turned or twisted (?)



%% ----------- MAIN -----------
%% Check if input file is used

if config.useInputFile
    usefulData = getUsefulData([config.inputFilePath config.inputFileName]);
    
    % Test if config data could be opened.
    if ~iscell(usefulData)
        error('Config file not found!');
    end
    
    % Number of Data
    numberOfFiles = size(usefulData{3},1);
else
    numberOfFiles = 1;
end


%% Logfile basics

writeLogBeg(config.useInputFile,config.use3D,config.logFilePath,config.logFileName);


%% Beginn of loop over data:

for fileIt=1:numberOfFiles

%% If input file is used, set folder and name
config.rotationAxis = 0;

if config.useInputFile
    config.folder  = usefulData{1}{fileIt};
    config.name    = usefulData{2}{fileIt};
    
    % Write on logfile
    writeLogPart(fileIt,[config.path config.data config.folder config.name config.extension],config.logFilePath,config.logFileName);

    config.horizontalstart  = usefulData{3}(fileIt);
    config.horizontalend    = usefulData{4}(fileIt);

    config.verticalstart    = usefulData{5}(fileIt);
    config.verticalend      = usefulData{6}(fileIt);
    
    config.rotationAxis     = usefulData{7}(fileIt);
end

config.saveflag = sprintf('_P_%d_s_%d',testParam,testSino);

% Link to data
%dataInfo.file = [config.path config.data config.folder config.name config.extension];

% Define cropping area (start pixel - end pixel, rectangular)
% Be careful HDF5 is turned 90° => Therefor switch axes.
dataInfo.cropsta = [config.horizontalstart , config.verticalstart];
dataInfo.cropend = [config.horizontalend , config.verticalend];

%% Make folder structure

% reco
%    --<name of experiment>
%         --<name of proj + flag>
%              --int
%              --sino
%              --tomo

saveCell = setSaveEnvironment(config.savepath,config.folder, config.name, config.saveflag);

% Check if making was succesful 
if true==saveCell{1}
    mainSavePath = saveCell{2};
else
    % If not add message to logfile
    writeOnLogfile('Save environment cannot be made! Skipping reconstruction.\n',config.logFilePath,config.logFileName);
    continue
end


%% Basic information of hdf5-data


%% Get number of Projections:
ang = config.maxAngle;
anz = (500-config.shiftProjnumber);
theta = 0 : ang/(500+1) : ang;

theta = theta(1:anz);


%% Get rotation axis
rotaxis = config.rotationAxis;

writeOnLogfile(sprintf('Rotaxis: %d\n',rotaxis),config.logFilePath,config.logFileName);

%% loop over read data
[xx,yy]=meshgrid((1:2048)-floor(2048/2),(1:2048)-floor(2048/2));
maskFullCircle = (xx.^2 + yy.^2) < 590^2;

% where are the intensities
intPath   = [config.inputPath config.folder config.name '_tie/int/'];
fileNames = dir([intPath 'corrint_*.tif']);

for proj = anz:-1:1
    % Read corrected data
    data = imread([intPath fileNames(proj).name]);
    
    XXX=size(data,1);
    YYY=size(data,2);
    
    % HardCrop!
    data=ifft2(ifftshift(fftshift(fft2(data,2048,2048)).*maskFullCircle));
    data=data(1:XXX,1:YYY);
    
    % Phase retrieval
    pha = ifft2(PhaseFilter('qp',size(data), [30 0.715 1.3e-6], (2.5), 0.1, 'double').*fft2(data));
  
    % crop length build sino
    sino(:,proj,:)=permute(shiftdim(pha,-1),[3 1 2]);
end

% Give mem free.
clear data;
clear pha;

% Save sinogram (not cropped!!!) - careful sinogram depends on cropping

height = config.verticalend - config.verticalstart + 1;

%if config.savesino
%    if config.use3D
%        for K = 1:height
%           write32bitTIF(sprintf('%ssino/sino_%05u.tif',mainSavePath, K), sino(:,:,K));
%        end
%    else
%        write32bitTIF(sprintf('%ssino/sino_%05u.tif',mainSavePath,config.depth), sino);
%    end
%end


% Rotation axis (cropping)
if config.use3D
    if rotaxis <= floor((config.horizontalend - config.horizontalstart +1)/2)
       sino = sino(1:round(rotaxis*2),:,:); 
    else
       sino = sino(round(rotaxis*2)-end:end,:,:);
    end
else
    if rotaxis <= floor((config.horizontalend - config.horizontalstart +1)/2)
        sino = sino(1:round(rotaxis*2),:);
    else
        sino = sino(round(rotaxis*2)-end:end,:);
    end
end

%% Tomogramm
useAstraReco(sino, mainSavePath);

% Give mem free for the next loop.
clear sino;
clear tomo;

end

writeLogEnd(config.logFilePath,config.logFileName);


