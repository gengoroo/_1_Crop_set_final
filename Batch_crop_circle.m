clear;
%------------------------------------------------------------
mfn = mfilename('fullpath');
[pn_main, fn_main] = fileparts(mfn);
pn_def = '';
fn_datalocation = [fn_main,'_datalocation.mat'];
if exist([pn_main '\' fn_datalocation],'file')
    load([pn_main '\' fn_datalocation]);
end
if pn_def == 0
    pn_def = '';
end
pn_crop2 = uigetdir(pn_def,'select crop2 folder');
pn_def = pn_crop2;
save([pn_main '\' fn_datalocation],'pn_def');
%------------------------------------------------------------

pn = uigetdir(pn_def,'Select movie foloder for circle crop');
radius = input('type radius <=0.5\n');

anglestep = input('type random_anglestep 0=no rotate\n');
pn_save = ['crop_circle_randrot_' num2str(radius)];
ListIM = dir(fullfile(pn, '*.avi'));


for id_fn = 1:numel(ListIM)
    if anglestep > 0
        nAngle = round(360/anglestep);
        angle = anglestep*randperm(nAngle,1);
    else
        angle = anglestep;
    end

    [fn_out, FrameRate] = crop_circle(ListIM(id_fn).name,pn,'radius',radius,'pn_save',pn_save,'angle',angle);
end
