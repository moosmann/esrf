function [yOut,xOut,SineArgPreFac,xMin] = makeRadInt(phase,edp,scaleVec,xMinArg,xMaxArg,xCut,yCut)

% prefac
SineArgPreFac = pi*EnergyConverter(edp(1))*edp(2)/(size(phase,1)*edp(3))^2; 

% size has to be even
[XX,YY]=meshgrid(-floor(size(phase,1)/2)+1:1:floor(size(phase,1)/2),-floor(size(phase,2)/2)+1:1:floor(size(phase,2)/2));

xPosRoom=(xCut<XX);
xNegRoom=(-xCut>XX);
yPosRoom=(yCut<YY);
yNegRoom=(-yCut>YY);

preRoom=(xPosRoom+xNegRoom).*(yNegRoom+yPosRoom);

RR=round(sqrt(XX.^2+YY.^2)).*preRoom;

xMin = floor(sqrt(xMinArg/(SineArgPreFac)));
xMax = ceil(sqrt(xMaxArg/(SineArgPreFac)));

x = xMin:xMax;

xNum=numel(x);
y=zeros(length(x),length(scaleVec));

% -------
energy      = edp(1); % in keV
lambda      = EnergyConverter(edp(1)); % in m
distance    = edp(2); % in m
pixelsize   = edp(3); % in m
[dimx,dimy] = size(phase);

% Fourier cooridnates.
[xi,eta] = meshgrid(-1/2:1/dimy:1/2-1/dimy,-1/2:1/dimx:1/2-1/dimx);
xi       = fftshift(xi);
eta      = fftshift(eta);

fprop    = (exp(-1i*pi*lambda*distance/(pixelsize^2)*(xi.^2+eta.^2)));

for kk = 1:length(scaleVec)   
    kk
    
    % Propagator.
    fu       = fft2(exp(1i*scaleVec(kk)*phase));
    int      = abs((ifft2(fprop.*fu))).^2;

    %int = Propagation(phaseSca,[edp(1) edp(2) edp(3)],1,'symmetric',0);

    % Substract mean.
    int = int-mean(int(:));
    
    %% Modulus of Fourier transform of intensity contrast
    fint = fftshift(fft2(int));
    afint = abs(fint);
    
    parfor jj=1:xNum
        y(jj,kk)=mean(afint((xMin-1+jj)==RR));
    end
    
    %y(:,kk)=y(:,kk)/max(y(:,kk));
end

xOut = SineArgPreFac*x.^2;
yOut = y;

