%% Function for using Astratoolbox for Reconstruction, ONLY 3D

function useAstraReco(sinogram,savepath)
% Basics
testSino = sinogram(:,:,1)';

angles = linspace2(0,pi/(size(testSino,1)+1)*size(testSino,1),size(testSino,1)+1);
angles = angles(1:size(testSino,1));

proj_geom = astra_create_proj_geom('parallel', 1.0, size(testSino,2), angles);
vol_geom  = astra_create_vol_geom(floor(size(testSino,2)),floor(size(testSino,2)));

zRange = 1:size(sinogram,3); 

clear testSino;

for ii = zRange
    % New sinogram
    sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, SubtractMean(sinogram(:,:,ii))');

    % If necessary define projection-op:
    % proj_id = astra_create_projector('linear', proj_geom, vol_geom); % only normal FBP

    % Configuration of algorithmus
    recon_id = astra_mex_data2d('create', '-vol', vol_geom, 0);
    cfg = astra_struct('FBP_CUDA');
    cfg.ProjectionDataId = sinogram_id;
    cfg.ReconstructionDataId = recon_id;

    % Reconstruct
    fbp_id = astra_mex_algorithm('create', cfg);
    astra_mex_algorithm('run', fbp_id);

    % Save data
    write32bitTIF(sprintf('%stomo/tomo_%05u.tif',savepath,ii), astra_mex_data2d('get', recon_id));

    % Garbage disposal
    astra_mex_data2d('delete', sinogram_id, recon_id);
    % astra_mex_projector('delete', proj_id);
    astra_mex_algorithm('delete', fbp_id);
end

end