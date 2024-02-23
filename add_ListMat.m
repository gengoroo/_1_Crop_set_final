function [ListMat, pn] = add_ListMat(pn,setting)
    %-----------------------------------------------------------------------------------------------
    % import settings
    nResize = setting.nResize;
    nAve = setting.nAve;

    nResize_original = nResize;% escape
    RangeData = ['resize[' num2str(nResize) ']_nAve' num2str(nAve) '_abs'];
    fprintf('Setting is %s\n',RangeData);
    %-----------------------------------------------------------------------------------------------
    FileList_avi = dir(fullfile(pn, '*.avi'));
    clear video;
    for id_movie = 1:numel(FileList_avi)

        fn_movie = FileList_avi(id_movie).name;
        FileCandi_ListMat = dir(fullfile(pn, [fn_movie(1:end-4),'*intensity.mat']));
        ListMat{id_movie} = FileCandi_ListMat(1).name;
        
        clear d_Intensity_resize;
        load([pn ,'\' ListMat{id_movie}]);
        nResize = nResize_original;%上のloadで上書きされるので、再設定
    
        fprintf('%d of %d: Making d_intensity_resize for %s\n',id_movie,numel(FileList_avi),FileList_avi(id_movie).name);
        video{id_movie} = VideoReader([FileList_avi(id_movie).folder ,'\' FileList_avi(id_movie).name]);
        nFrames = video{id_movie}.NumFrames;
        clear MovieData;
        for id_frame=1:nFrames
          MovieData(:,:,id_frame)=rgb2gray(read(video{id_movie},id_frame));% average color Ch
        end
        MovieData_resize = imresize3(MovieData,[nResize(1),nResize(2),nFrames/nResize(3)]);
        d_MovieData_resize_abs = abs(MovieData_resize(:,:,2:end) - MovieData_resize(:,:,1:end-1));
        d_Intensity_resize_abs = reshape(sum(sum(d_MovieData_resize_abs,1),2),[],1);
        save([pn ,'\' ListMat{id_movie}],'d_Intensity_resize_abs','RangeData','-append');%上書き

    end
    %-----------------------------------------------------------------------------------------------
end