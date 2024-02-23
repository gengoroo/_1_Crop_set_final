%MovCrop_1st
clear;close all;
pn_movie = 'C:\Users\gengoro\_Data';
fn_movie = '';% all mp4 or AVI files
yn_continue = 1;
counter = 0;
while(yn_continue)
    counter = counter +1;
	List_pn_movie{counter} = uigetdir(pn_movie,'selct multiple mp4 folder, cancel to stop');
    if List_pn_movie{counter} == 0
        yn_continue = 0;
        List_pn_movie(counter) = [];
    end
end
note = input('type note to name folder\n','s');
RangeFrame = [45*30:74*30];%[44*30:73*30];
RangeDIM1 = [];
RangeDim2 = [];
Listfn = '';
for ii = 1:numel(List_pn_movie)
    if ii > 1
        yn_skip = 'y';
    else
        yn_skip = 'n';
    end
    [ListDim1,ListDim2,ListFrames] = mov_crop(Listfn,List_pn_movie{ii},RangeDIM1,RangeDim2,RangeFrame,'yn_skip',yn_skip,'note',note);
    save([List_pn_movie{ii} '\CropSetting.mat'],'RangeDIM1','RangeDim2','RangeFrame');
end
fprintf('Next to run is SelectMovieFileFrame.m\n');