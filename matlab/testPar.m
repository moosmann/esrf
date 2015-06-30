parfolder = '/mntdirect/_data_visitor/ls2395/id19/';
name = '19th_04h06m12_Stage24_Gap22p5_sequ1sample_1_';
folder = [parfolder name];
ref = Readstack(folder, 1,'ref*_0000.edf');
flat = median(ref, 3);
proj = Readstack(folder, 1,[name '0002.edf']);
int = proj ./ flat;
fprintf('\n')

figure(1)
zz = 4.4;
for nn = 1:100
    
    pf = abs(fftshift(PhaseFilter('qp',size(int),[26.2 zz 1.6e-6],0.1,0.0001)));
    intf = log(1+abs(fftshift(fft2(SubtractMean(int)))));
    %itool(pf)
    %itool(intf)
    x = round(size(pf,2)/2);
    pf1 = 1-normat(pf(:,1:x));
    intf1 = normat(intf(:,x+1:end));
    
    title(sprintf('distance %f',zz))
    im2 = [pf1,intf1];
    xx = round(size(im2,1)*0.3):round(size(im2,1)*0.7);
    yy = round(size(im2,2)*0.3):round(size(im2,2)*0.7);
    im2 = im2(xx, yy);
    imagesc(im2)
    colormap gray
    title(sprintf('distance %f',zz))
    
    pause(1)
    zz = input('Enter z:');
    
end