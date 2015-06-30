
filestring = 'C:\Users\Steffen\Documents\propaStuff\lena.tif'; %'manhattenTest.tif';%

energy = 20;
distance = 0.5;
pixelsize = 1.1e-6;

lambda=EnergyConverter(energy);

rescalVec = 1:500;

img0    =double(imread(filestring)); %phantom(2001);

img=zeros(2000);
img=img0(1:end-1,1:end-1);

blurring=[7,7,1];
img=imfilter(img,fspecial('gaussian',[blurring(1) blurring(2)],blurring(3)));



%% Read image and pad it with zeros.
paddim = 4096;

phase0 = zeros(paddim,paddim);
phase0(paddim/2+(-999:1000),paddim/2+(-999:1000)) = 0.01*normat(img);

tic;
%[yOut,xOut,SineArgPreFac,xMin] = makeRadInt(phase0,[energy, distance, pixelsize],rescalVec,pi/4,7*pi/4,5,5);
toc

xPos1 = floor(sqrt(3*pi/(4*SineArgPreFac)))-xMin;
xPos2 = ceil(sqrt(5*pi/(4*SineArgPreFac)))-xMin;

% ----------------------------------------------

%save('testRun');

for kk = length(rescalVec):-1:1

    %cF{kk} = fitRadMeanLine(xOut,yOut(:,kk),10,-10,(kk-1)*0.001);
    cF{kk} = fitRadMeanLine_2(xOut(xPos1:xPos2),yOut(xPos1:xPos2,kk),10,-10,(kk-1)*0.001);
    %cF_2{kk} = fitRadMeanLine(xOut,yOut(:,kk),rescalVec(kk)*100,-rescalVec(kk)*10,1);
    %[cfMaxVal(kk) cfMaxPos(kk)] = max(cf{kk}(SinArg(xPos1:xPos2)));
    %[cfMinVal(kk) cfMinPos(kk)] = min(cf{kk}(SinArg(xPos1:xPos2)));
    
%     f = figure('visible','off');
%     axis([0 2*pi 0 1.05])    
% 	plot(xOut,cF{kk}(xOut),xOut,yOut(:,kk))
%     axis([0 2*pi 0 1.05])  
%     saveas(f,sprintf('fits/rads_S_%04u.png',kk),'png')
    
    testMin(kk)=fminbnd(cF{kk},3*pi/4,3*pi/2);
    %testMin_2(kk)=fminbnd(cF_2{kk},3*pi/4,3*pi/2);
end


parameterL= 2*pixelsize/sqrt(pi*lambda*distance);




