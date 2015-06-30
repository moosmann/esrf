figure(1)
parfolder = '/mntdirect/_data_visitor/ls2395/id19/';

datasetname = '20th_12h23m42_Stage20_Gap18p5_sequ1sample_1_';

% 'testage22_4x_100umGGG_543cm_gap15__';
% '19th_01h39m39_Stage23_Gap22p5_sequ1sample_1_';
% '18th_20h36m26_Stage22Cad11moGap22p5_sequ1sample_1_';
% 'testRodenstock5mu_2p3muPx_LuAG100_5mprop';

tic
if 1
    for nn = 500:-1:1
        filename = sprintf('%s%s/%s%04u.edf', parfolder, datasetname, datasetname, nn);
        sino(:, nn) = edfread(filename,1:1280,830)'; %edfread(filename,1:2560,1200)';
        %im = edfread(filename)';
        if 0
            imagesc(im)
            colormap gray
            pause(0.01)
        end
    end
end
disp(toc)
clear rec
if 1
    angles_deg = (1:500)/500*180;
    angles_rad = (1:500)/500*pi;
    for nn = 40:-1:1
        %rec(:,:,nn) = astra_make_fbp(SubtractMean(sino(round(size(sino,1)/2)+(nn-20)+(-800:800),:)'), angles_rad);
        rec=iradon(RotAxisSymmetricCropping(sino',round(size(sino,1)/2)+nn-20)',angles_deg);
        if 1
            imagesc(rec); %(:,:,nn)),
            title(sprintf('nn = %u', round(size(sino,1)/2)+nn-20))
            colormap gray
            %pause(5)
        end
        input('hit enter  ')
    end
end