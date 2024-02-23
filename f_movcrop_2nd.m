function f_movcrop_2nd(fn_SelectCut)

    %MovCrop_2nd
    % Input: List_fn_out_movie, List_total_stack
    %pn_def = 'Z:\Bahavior\PTZ\PTZ20230717-1\crop_PTZ00uM';
    %[fn_List_movie_crop_data, pn_List_movie_crop_data] = uigetfile([pn_def, '\List_movie_crop_data.mat'], 'select List_movie_crop_data');
    %load([pn_List_movie_crop_data ,'\' fn_List_movie_crop_data]);
    %load(fn_List_movie_crop_data);
    %[fn_SelectCut, pn_SelectCut] = uigetfile([pn_List_movie_crop_data, '\SelectCut.mat'], 'select SelectCut.mat');
    %load([pn_SelectCut, fn_SelectCut]);
    load(fn_SelectCut,'ListFnMovie','ListCutMovie','setting','RangeData');
    nAve = setting.nAve;
    
    %pn_out_movie = pn_List_movie_crop_data;% 
    pn_out_movie = fileparts(fn_SelectCut);% 
    
    %pn_save = [pn_SelectCut,'\crop_' RangeData];
    pn_save = [fileparts(fn_SelectCut),'\crop_' RangeData];

    mkdir(pn_save);
    for ii = 1:numel(ListFnMovie)
        temp = char(ListFnMovie(ii));
        fn_movie = [temp(1:end-3), '.avi'];
        video = VideoReader([pn_out_movie ,'\' fn_movie]);
        nMaxFrames = video.NumFrames;
        RangeDIM1 = 1:video.Height;
        RangeDim2 = 1:video.Width;
        start_cut = ListCutMovie(ii);
        RangeFrame = (start_cut-1)*nAve+1:min(nMaxFrames,start_cut*nAve);
        f_mov_crop(fn_movie,pn_out_movie,RangeDIM1,RangeDim2,RangeFrame,'yn_manual_crop','n','pn_save',pn_save);
    end

end