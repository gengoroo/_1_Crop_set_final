function [fn_SelectCut, setting] = f_SelectMovieFileFrame(pn,setting,varargin)

   nAve  = setting.nAve;
    %-----------------------------------------------------------------------------------------------
    FileList = dir(fullfile(pn, '*_intensity.mat'));

    ListFnMovie_all = categorical;
    counter = 0;
    for ii = 1:numel(FileList)
        ListMat{ii} = FileList(ii).name;
        
        load([pn '\' ListMat{ii}]);
        nAve= setting.nAve;
        nResize = setting.nResize;

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
    
    h1 = figure('Name',['hist_d_Intensity_set_ave TW ' num2str(nAve) 'frames_' RangeData]);
    histogram(d_Intensity_serial);hold on;
    if ~exist('Range_d','var')
        Range_d = input('Type RangeValue in 1x2 vector for Range_d [] for all\n');
    end
    setting.Range_d = Range_d;
    plot(Range_d(1),0,'r+');
    plot(Range_d(2),0,'r+');

    List_d = intersect(find(d_Intensity_serial>=Range_d(1)), find(d_Intensity_serial<=Range_d(2)));
    List_total_stack = List_total_stack_all(List_d,:);
    ListFnMovie(:,1) = ListFnMovie_all(List_d);
    ListCutMovie(:,1) = ListCutMovie_all(List_d);

    RangeData = [RangeData '_' num2str(Range_d(1)) '-' num2str(Range_d(2))];
    
    h2 = figure('Name',['plot_d_Intensity_set_ave TW ' num2str(nAve) 'frames_' RangeData]);
    plot(d_Intensity_serial);hold on;
    a=gca;
    plot(a.XLim,[Range_d(1),Range_d(1)]);
    plot(a.XLim,[Range_d(2),Range_d(2)]);
    UniListFnMovie = unique(ListFnMovie_all);
    for id_fn = 1:numel(UniListFnMovie)
        id_first = find(UniListFnMovie(id_fn)==ListFnMovie_all, 1 );
        if ~isempty(id_first)
            plot([id_first id_first],a.YLim);
            text(id_first,d_Intensity_serial(id_first),char(UniListFnMovie(id_fn)),'Interpreter','none');
        end
    end
    
    %-----------------------------------------------------------------------------------------------
    %-----------------------------------------------------------------------------------------------
    fn_SelectCut = [pn,'\SelectCut_' RangeData '.mat'];
    save(fn_SelectCut,'ListMat','setting','d_Intensity_serial','ListFnMovie','ListCutMovie','ListFnMovie_all','ListCutMovie_all',...
        'List_d','List_total_stack','RangeData');
    saveas(h1,[pn,'\' h1.Name '.fig'],'fig');
    saveas(h2,[pn,'\' h2.Name '.fig'],'fig');
    %-----------------------------------------------------------------------------------------------
end
