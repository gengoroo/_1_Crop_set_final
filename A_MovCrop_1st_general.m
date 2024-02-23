%MovCrop_1st
pn_movie = 'Z:\movie_stock';
fn_movie = '';% all mp4 or AVI files
output_imsize = [20,20]*10; %20x20?RF?10??????????
fprintf('Color will be turned to grayscale\n');
fprintf('output image size is %s\n',num2str(output_imsize));

yn_continue = 1;
counter = 0;
while(yn_continue)
    counter = counter +1;
	List_pn_movie{counter} = uigetdir(pn_movie,'selct mutiple mp4 folder, cancel to exit');
    if List_pn_movie{counter} == 0
        yn_continue = 0;
        List_pn_movie(counter) = [];
    end
end
RangeFrame = input('Type RangeFrame []:all\n');%all area
RangeDIM1 = input('Type RangeDIM1 []:all\n');%all area
RangeDim2 = input('Type RangeDim2 []:all\n');%all frames
Listfn = '';% full_frame
for ii = 1:numel(List_pn_movie)
    if ii > 1
        yn_skip = 'y';
    else
        yn_skip = 'n';
    end
    [ListDim1,ListDim2,ListFrames] = mov_crop(Listfn,List_pn_movie{ii},RangeDIM1,RangeDim2,RangeFrame,'yn_skip',yn_skip,'output_imsize',output_imsize,'yn_manual_crop','n');
    save([List_pn_movie{ii} '\CropSetting.mat'],'RangeDIM1','RangeDim2','RangeFrame');
end
fprintf('Next to run is SelectMovieFileFrame.m\n');