archStr='/data/visitor/ls2395/id19';
%foldStr='test_4x_100umGGG_643cm_2b_';
foldStr='20th_14h17m30_Stage20_Cad11moGap22p5N500_sequ1sample_1_';

%'20th_10h30m46_Stage19_cad11mo_sequ1sample_1_';

xCut=5;
yCut=5;

projFiles=dir([archStr '/' foldStr '/' foldStr '*.edf']);
refeFiles=dir([archStr '/' foldStr '/' 'ref*0000.edf']);

clear('ref0');

ref    =0;
projFFT=0;

% get ref
fprintf('Making ref...\n')
tic
for ii=numel(refeFiles):-1:1
    ref0(:,:,ii)=pmedfread([archStr '/' foldStr '/' refeFiles(ii).name]);
end
ref=median(ref0,3);
toc


% get projFFT
fprintf('Making projFFT...\n')
tic
for ii=1:numel(projFiles)
    projFFT=projFFT+abs(fft2(pmedfread([archStr '/' foldStr '/' projFiles(ii).name])./ref));
end
projFFT=fftshift(projFFT/numel(projFiles));
projFFT_1=fftshift(abs(fft2(pmedfread([archStr '/' foldStr '/' projFiles(floor(numel(projFiles)/2)).name])./ref)));
toc

% make rad int
fprintf('Making rad...\n')
tic
if size(projFFT,1)<size(projFFT,2)
    corr=1-mod(size(projFFT,2),2);
    [XX,YY]=meshgrid(linspace(-floor(size(projFFT,2)/2)+corr,floor(size(projFFT,2)/2),size(projFFT,1)),-floor(size(projFFT,2)/2)+corr:1:floor(size(projFFT,2)/2));
    maxVal=floor(size(projFFT,2)/2);
else
    corr=1-mod(size(projFFT,1),2);
    [XX,YY]=meshgrid(-floor(size(projFFT,1)/2)+corr:1:floor(size(projFFT,1)/2),linspace(-floor(size(projFFT,1)/2)+corr,floor(size(projFFT,1)/2),size(projFFT,2)));
    maxVal=floor(size(projFFT,1)/2);
end

XX=XX';
YY=YY';

xPosRoom=(xCut<XX);
xNegRoom=(-xCut>XX);
yPosRoom=(yCut<YY);
yNegRoom=(-yCut>YY);

preRoom=(xPosRoom+xNegRoom).*(yNegRoom+yPosRoom);

RR=round(sqrt(XX.^2+YY.^2)).*preRoom;

yOut=zeros(1,maxVal);
yOut_1=zeros(1,maxVal);
for ii=1:maxVal
    yOut(1,ii)=mean(projFFT(ii==RR));
    yOut_1(1,ii)=mean(projFFT_1(ii==RR));
end
toc
%pola=cart2pol();

x=100:600;
y=yOut(1,x);
y_2=yOut_1(1,x);

x=x(:)/maxVal;
y=y(:)/max(y(:));
y_2=y_2(:)/max(y_2(:));

[val,pos]=min(y)
x(pos)

[val_2,pos_2]=min(y_2)
x(pos_2)

ca;plot(x,y,x,y_2)

EnergyConverter(((x(pos)*1/(2*1.6e-6))^2*3.12)^(-1)) % can be used both ways!
