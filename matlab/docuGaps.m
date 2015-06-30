archStr='/data/visitor/ls2395/id19';
saveStr='/data/visitor/ls2395/stats/testgap';


folderStr={'17th_19h23m31_stage23doseTestgap22p5_',
'17th_19h25m21_stage23doseTestgap23p5_',
'17th_19h27m06_stage23doseTestgap21p5_',
'17th_19h28m51_stage23doseTestgap20p5_',
'17th_19h30m21_stage23doseTestgap19p5_',
'17th_19h31m48_stage23doseTestgap18p5_',
'17th_19h33m13_stage23doseTestgap17p5_',
'17th_19h34m37_stage23doseTestgap16p5_',
'17th_19h36m05_stage23doseTestgap15p5_'};

for ii=1:numel(folderStr)
    img=log(1+abs(fftshift(fft2(pmedfread([archStr '/' folderStr{ii} '/' folderStr{ii} '0010.edf'])./pmedfread([archStr '/' folderStr{ii} '/' 'ref0000_0000.edf'])))));
    img=img-min(img(:));
    img=img/max(img(:));
    
    imwrite(img,[saveStr '/' folderStr{ii} '.png'],'png');
end

