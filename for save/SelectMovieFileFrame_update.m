%SelectMovieFileFrames
clear;close all;
yn_remake_d_Intensity_resize = input('remake d_Intensity_resize y/n\n','s');
nAve = 60;% frames
nResize_original = [20 20 15];% 20pix 20pix 15frames 　smoothing of T dim is important to remove flicker light effect

fprintf('Put all cropped movie files in a signle folder\n');
pn_def = 'Z:\Bahavior\PTZ\PTZ20230717-1\crop_PTZ00uM';
%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
% Updated version
pn = uigetdir(pn_def, '');
FileList = dir(fullfile(pn, '*.avi'));
clear video;
for id_movie = 1:numel(FileList)
    ListMat{id_movie} = [FileList(id_movie).name(1:end-4), '_intensity.mat'];
    clear d_Intensity_resize;
    load([pn ,'\' ListMat{id_movie}]);
    nResize = nResize_original;%上書き

    if ~exist('d_Intensity_resize_abs','var')||(yn_remake_d_Intensity_resize == 'y')
        fprintf('%d of %d: Making d_intensity_resize for %s\n',id_movie,numel(FileList),FileList(id_movie).name);
        video{id_movie} = VideoReader([FileList(id_movie).folder ,'\' FileList(id_movie).name]);
        nFrames = video{id_movie}.NumFrames;
        clear MovieData;
        for id_frame=1:nFrames
          MovieData(:,:,id_frame)=rgb2gray(read(video{id_movie},id_frame));% average color Ch
        end
        MovieData_resize = imresize3(MovieData,[nResize(1),nResize(2),nFrames/nResize(3)]);
        d_MovieData_resize_abs = abs(MovieData_resize(:,:,2:end) - MovieData_resize(:,:,1:end-1));
        d_Intensity_resize_abs = reshape(sum(sum(d_MovieData_resize_abs,1),2),[],1);
        save([pn ,'\' ListMat{id_movie}],'d_Intensity_resize_abs','-append');%上書き
    end
end
%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
clear d_Intensity_serial;
clear ListFnMovie_all;
ListFnMovie_all = categorical;
counter = 0;
for ii = 1:numel(ListMat)
    
    load([pn '\' ListMat{ii}]);
    d_Intensity = d_Intensity_resize_abs;%　置き換え
    nSet = floor(numel(d_Intensity)/(nAve/nResize(3)));
    d_Intensity_fold = reshape(d_Intensity(1:nSet*(nAve/nResize(3))),nSet,(nAve/nResize(3)));% average within TW
    d_Intensity_set_ave = mean(d_Intensity_fold,2);

    List = (counter + 1):(counter + nSet);
    counter = counter + nSet;

    d_Intensity_serial(List,1) = d_Intensity_set_ave;

    ListFnMovie_all(List) = [extractBefore(ListMat{ii},'_intensity'), 'avi'];
    ListCutMovie_all(List) = 1:numel(d_Intensity_set_ave);

    List_total_stack_all(List,1) = ii;
    List_total_stack_all(List,2) = 1:numel(d_Intensity_set_ave);

end

Range_d = input('Type RangeValue in 1x2 vector for Range_d [] for all\n');
List_d = intersect(find(d_Intensity_serial>=Range_d(1)), find(d_Intensity_serial<=Range_d(2)));
List_total_stack = List_total_stack_all(List_d,:);
ListFnMovie(:,1) = ListFnMovie_all(List_d);
ListCutMovie(:,1) = ListCutMovie_all(List_d);

RangeData = ['resize[' num2str(nResize) ']_abs_' num2str(Range_d(1)) '-' num2str(Range_d(2))];

h1 = figure('Name',['hist_d_Intensity_set_ave TW ' num2str(nAve) 'frames_' RangeData]);
hist(d_Intensity_serial);hold on;
plot(Range_d(1),0,'r+');
plot(Range_d(2),0,'r+');

h2 = figure('Name',['plot_d_Intensity_set_ave TW ' num2str(nAve) 'frames_' RangeData]);
plot(d_Intensity_serial);

UniListFnMovie = unique(ListFnMovie);
for id_fn = 1:numel(UniListFnMovie)
    id_first = find(ListFnMovie==UniListFnMovie(id_fn), 1 );
    text(id_first,0,char(UniListFnMovie(id_fn)));
end

%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
save([pn,'\SelectCut_' RangeData '.mat'],'ListMat','nAve','d_Intensity_serial','ListFnMovie','ListCutMovie','Range_d',...
    'List_d','List_total_stack','video','RangeData');
saveas(h1,[pn,'\' h1.Name '.fig'],'fig');
saveas(h2,[pn,'\' h2.Name '.fig'],'fig');
%-----------------------------------------------------------------------------------------------
