%function f_movcrop_custom()
clear;close all;
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
pn_movie = uigetdir(pn_def,'select pn_movie');
pn_def = pn_movie;
save([pn_main '\' fn_datalocation],'pn_def');
%------------------------------------------------------------

    pn_mov = uigetdir(pn_def,'select movie folder');
    ListFnMovie = dir(fullfile(pn_mov,'*.avi'));

    samplevideo = VideoReader([ListFnMovie(1).folder ,'\' ListFnMovie(1).name]);
    fprintf('1st video is\n');
    fprintf([ListFnMovie(1).name, '\n']);
    fprintf('%d frames %d seconds\n',samplevideo.NumFrames, round(samplevideo.NumFrames/samplevideo.FrameRate));
    sec_div = input('How many sec for 1 cut []=2\n');
    if isempty(sec_div)
        sec_div = 2;
    end

    im_1st=read(samplevideo,1);
    h = figure('Name','1st movie 1st frame');imshow(im_1st);
    n_div_side = input('How many div for side');

    yn_1stcutonly = input('use 1st cut only y/n','s');
    yn_1gridonly = input('use 1st grid only y/n','s');

    close(h);

    pn_save = [pn_mov,'\cropcustom_' num2str(n_div_side) 'div' num2str(sec_div) 'sec'];
    if ~exist(pn_save,'dir')
        mkdir(pn_save);
    end

    [Xstart, Ystart] = meshgrid(0:n_div_side - 1, 0:n_div_side - 1);
    ListStartDim1 = 1 + Xstart * floor(size(im_1st,1) / n_div_side);
    ListStartDim2 = 1 + Ystart * floor(size(im_1st,2) / n_div_side);

    ListEndDim1 = ListStartDim1 + floor(size(im_1st,1) / n_div_side) - 1;
    ListEndDim2 = ListStartDim2 + floor(size(im_1st,2) / n_div_side) - 1;

    if yn_1gridonly == 'y'
        nTotalGrid = 1;
    else
        yn_one_side_only = input('use grids on one side only y/n, n:all grids \n','s');
        if yn_one_side_only == 'y'
            nTotalGrid = n_div_side;
            
        else
            nTotalGrid = n_div_side*n_div_side;
        end
    end
    fprintf('Total %d grids\n',nTotalGrid);
    
    for id_grid = 1:nTotalGrid
        [y, x] = ind2sub([n_div_side, n_div_side],id_grid);

        RangeDim1{id_grid} = ListStartDim1(x,y):ListEndDim1(x,y);
        RangeDim2{id_grid} = ListStartDim2(x,y):ListEndDim2(x,y);

        if isempty(RangeDim1{id_grid})
            fprintf('Range Dim1 Empty');
        end
        if isempty(RangeDim2{id_grid})
            fprintf('Range Dim2 Empty');
        end
    end
   
    for ii = 1:numel(ListFnMovie)

        video = VideoReader([ListFnMovie(ii).folder ,'\' ListFnMovie(ii).name]);
        fn_in = ListFnMovie(ii).name(1:end-4);

        nFrameCut = sec_div * video.FrameRate;
        lastframe = floor(video.NumFrames/nFrameCut)*nFrameCut;

        if yn_1stcutonly == 'y'
            ListFrameStart = 1;
            ListFrameEnd = nFrameCut;
        else
            ListFrameStart = 1:nFrameCut:lastframe;
            ListFrameEnd = unique([ListFrameStart(2:end)-1, lastframe]);
        end

        for id_grid = 1:nTotalGrid

            ListDim1 = RangeDim1{id_grid};
            ListDim2 = RangeDim2{id_grid};

            for id_start = 1:numel(ListFrameStart)
                fn_out = [fn_in '_grid[' num2str(ListDim1(1)) '_' num2str(ListDim2(1)) ']_frame[' num2str(ListFrameStart(id_start)) '_' num2str(ListFrameEnd(id_start)) ']'];
                writerObj1 = VideoWriter([pn_save '\' fn_out  '.avi']);
                writerObj1.FrameRate = video.FrameRate;
                open(writerObj1);
                if ListFrameEnd(id_start) < ListFrameStart(id_start)
                    fprintf('Start Frame is after End Frame');
                end
                for id_frame = ListFrameStart(id_start):ListFrameEnd(id_start)
                    im=read(video,id_frame);
                    if isempty(im)
                        fprintf('Image is empty\n');
                    end
                    writeVideo(writerObj1,im(ListDim1, ListDim2, :));  
                end
                close(writerObj1);
            end
        end

    end
%end