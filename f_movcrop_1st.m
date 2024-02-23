%MovCrop_1st
%clear;close all;
%pn_movie = 'Z:\Bahavior\PTZ\PTZ20230717-1';
%fn_movie = '';% all mp4 or AVI files
function pn_save = f_movcrop_1st(pn,RangeFrame,varargin)
    Listfn = '';
    for ii = 1:nargin-2
        if strcmp(varargin{ii},'Listfn')
            Listfn = varargin{ii+1};
            for kk = 1:numel(Listfn)
                fprintf('Selected files are %s\n',Listfn{kk})
            end
        end
    end

    % if RangeFrame is empty, f_mov_crop takes all frames
    note = input('type note to name folder\n','s');

    [fn_List_movie_crop_data, pn_List_movie_crop_data] = uigetfile([pn '\List_movie_crop_data.mat'],'Select List_movie_crop_data.mat OR cancel to specify crop area by a mouse');
    if fn_List_movie_crop_data~=0
        load([pn_List_movie_crop_data '\' fn_List_movie_crop_data],'ListDim1','ListDim2','Circle3P');
    else
        RangeDIM1 = [];
        RangeDim2 = [];
        
    end
    if exist('Circle3P')
        RangeDIM1 = [];
        RangeDim2 = [];       
        [ListDim1,ListDim2,ListFrames,pn_save,note] = f_mov_crop(Listfn,pn,RangeDIM1,RangeDim2,RangeFrame,'Circle3P',Circle3P,'yn_skip','n','note',note);
        save([pn '\CropSetting_' note '.mat'],'Circle3P');
    else
        [ListDim1,ListDim2,ListFrames,pn_save,note] = f_mov_crop(Listfn,pn,RangeDIM1,RangeDim2,RangeFrame,'yn_skip','n','note',note);
        save([pn '\CropSetting' note '.mat'],'ListDim1','ListDim2','RangeFrame');
    end
    
end
