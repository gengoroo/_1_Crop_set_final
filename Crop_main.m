%Crop_main
clear;
close all;
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
pn_def = uigetdir(pn_def,'select pn_def folder');
save([pn_main '\' fn_datalocation],'pn_def');
%------------------------------------------------------------

selector = input('start process 1:crop1 2:add to ListMat 3: SelectCuts 4:make cut movies 5: rotate_movies 6: divide_movies[optiopnal] 7: shuffle movie subfolder');
%-------------------------------------------------
if selector<=1
    selector_crop1 = input('1:PTZ 2:General such as fountarin \n');
    yn_allfile = input('All file=y \Single file=n\n','s');
    if yn_allfile == 'y'
        LisFiles = dir(fullfile(pn_def,'*.mp4'));
        for id_file = 1:numel(LisFiles)
            Listfn{id_file} = LisFiles(id_file).name;
        end
    else
        Listfn{1} = uigetfile([pn_def '\*.mp4'],'Select a movie file to crop');
    end

    % if RangeFrame is empty, f_movcrop_1st takes all frames

    switch selector_crop1
        case 0
            pn_input = uigetdir(pn_def,'selct mp4 folder');

        case 1
            % trim unneccesary time and areas
            pn_input = uigetdir(pn_def,'selct mp4 folder');
            RangeFrame = input('Type range of movie frames to import []=45*30:74*30 for tad movies\n');
            if isempty(RangeFrame)
                RangeFrame = 45*30:74*30;
            end
            pn = f_movcrop_1st(pn_input,RangeFrame,'Listfn',Listfn);
            pn_def = pn;

        case 2
            A_MovCrop_1st_general;
    end
end
%-------------------------------------------------
if selector <=2
    % Add d_intensity_resized_abs to ListMat
    if ~exist('pn','var')
        pn = uigetdir(pn_def,'selct crop1 folder');
    end
    setting.nResize = [20 20 15];% divide into 20grid, 20grid, average 15 frames
    setting.nAve = 60;%frames for final average
    [ListMat, pn] = add_ListMat(pn,setting);
    pn_def = pn;
end
%-------------------------------------------------
if selector<=3
    % find appropriate cuts
    if ~exist('pn','var')
        pn = uigetdir(pn_def,'selct crop1 folder');
        setting.nResize = [20 20 15];% divide into 20grid, 20grid, average 15 frames
        setting.nAve = 60;%frames for final average
    end
    fn_SelectCut = f_SelectMovieFileFrame(pn,setting);
    pn_def = pn;
end
%-------------------------------------------------
if selector<=4
    if ~exist('fn_SelectCut','var')
        [fn_temp, pn_temp] = uigetdir(pn_def,'selct crop1 folder');
        fn_SelectCut = [pn_temp, fn_temp];
    end
    f_movcrop_2nd(fn_SelectCut);
end
%-------------------------------------------------
if selector==5
    Batch_crop_circle;
end
%-------------------------------------------------
if selector==6
    f_movcrop_custom;
end
%-------------------------------------------------
if selector == 7
    shuffle_subfolders;
end
%-------------------------------------------------