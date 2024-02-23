% ??????????????????????????
function  [ListDim1,ListDim2,ListFrames] = mov_crop(Listfn,pn,ListDim1,ListDim2,ListFrames,varargin)
    %fprintf('type MovCrop(Listfn,pn,ListDim1,ListDim2,ListFrames) to run this code');
    
    yn_manual_crop = 'y';
    note = '';
    size_resize = [20, 20];
    for ii = 1:nargin-5
        if strcmp(varargin{ii}, 'yn_manual_crop')
            yn_manual_crop = varargin{ii+1};
        end
        if strcmp(varargin{ii}, 'note')
            note = ['_' varargin{ii+1}];
        end 
        if strcmp(varargin{ii}, 'pn_save')
            pn_save = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'output_imsize')
            output_imsize = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'size_resize')
            size_resize = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'yn_skip')
            yn_skip = varargin{ii+1};
            if yn_skip == 'y'
                yn_manual_crop = 'n';
            end
        end
    end
    
    if yn_manual_crop == 'y'
        [fn_crop, pn_crop] = uigetfile([pn '\*'],'select mov for mouse crop');
        video = VideoReader([pn_crop ,'\' fn_crop]);
        fprintf('Total frames are %d\n',video.NumberOfFrames);
        id_frame = input('Type Frame# to click\n');
        im = read(video,id_frame);
        figure;imshow(im);hold on;
        
        if ~isempty(ListDim1)&&~isempty(ListDim2)
            plot([ListDim1(1),ListDim1(1),ListDim1(end),ListDim1(end)],[ListDim2(1),ListDim2(end),ListDim1(end),ListDim1(1)]);
        else
            fprintf('Click 4 corners\n');
            for ii = 1:4
                [x(ii),y(ii)]= ginput (1);
                plot(x(ii),y(ii),'r.');
            end
            fprintf('x (DIM2) is %s\n',num2str(x));
            fprintf('y (DIM1) is %s\n',num2str(y));
            ListDim1 = ceil(min(y)):floor(max(y));
            ListDim2 = ceil(min(x)):floor(max(x));
        end
         
         yn_respecify = input('Resecify crop XY by typing number ?y/n','s');
         if yn_respecify == 'y'
             ListDim1 = input('Type Dim1 all Y data\n');
             ListDim2 = input('Type Dim2 all X data \n');
             ListFrames = input('Type Frame add Frame data\n');
         end
    end
    
    if ~exist('output_imsize','var')
        output_imsize = '';
    end
    
	if ~exist('pn_save','var')
        pn_save = [pn '\crop' note];
    end
        
    if ~isempty(Listfn) % if Listfn is specified, the files will be cropped
        if ~iscell(Listfn)
            temp = Listfn;
            clear Listfn;
            Listfn{1} = temp;
        end
        for id_fn = 1:numel(Listfn)
            fn = Listfn{id_fn};
            [Listfn_out{id_fn}, FrameRate(id_fn)] = crop(fn,pn,ListDim1,ListDim2,ListFrames,'pn_save',pn_save,'output_imsize',output_imsize);
        end
    else % If only pn is specified, all movie files will be cropped
        Info = dir(pn);
        counter = 0;
        for id_fn = 1:numel(Info)
            fn = Info(id_fn).name;
            if ~isempty(strfind(fn,'mp4'))||~isempty(strfind(fn,'avi'))
                counter = counter + 1;
                
                fprintf('%d ', counter);
                [Listfn_out{counter}, FrameRate(counter)] = crop(fn,pn,ListDim1,ListDim2,ListFrames,'pn_save',pn_save,'output_imsize',output_imsize);
            end
        end
    end
    List_fn_out_movie = Listfn_out;
    

    pn_out_movie = pn_save;
	if ~exist(pn_save,'dir')
        mkdir(pn_save);
    end
    save([pn_save, '\List_movie_crop_data.mat'],   'List_fn_out_movie','pn_out_movie','FrameRate','ListDim1','ListDim2','ListFrames','note');
end

function [fn_out, FrameRate] = crop(fn,pn,ListDim1,ListDim2,ListFrames,varargin)

    for ii = 1:nargin-5
        if strcmp(varargin{ii}, 'pn_save')
            pn_save = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'output_imsize')
            output_imsize = varargin{ii+1};
        end 
    end
    
    vid1=VideoReader([pn ,'\' fn]);
    n=vid1.NumberOfFrames;
    if isempty(ListFrames)
        ListFrames = 1:n;
    end
    %-----------------------
    im=read(vid1,1);
    if isempty(output_imsize)
        output_imsize = [size(im,1), size(im,2)];
    end
    fprintf('%s: %d x %d x %d Frames => %d x %d x %d Frames ',fn, size(im,1), size(im,2), n, numel(output_imsize(1)), numel(output_imsize(2)),numel(ListFrames));
    
    if ~exist('pn_save','var')
        pn_save = [pn '\crop'];
    end
    if ~exist(pn_save,'dir')
        mkdir(pn_save);
    end
    
    fn_base = [fn(1:end-4) '_crop' num2str(ListFrames(1))];
    
    fn_out = [fn_base '.avi'];
    writerObj1 = VideoWriter([pn_save '\' fn_out]);
    writerObj1.FrameRate = vid1.FrameRate;
    FrameRate = writerObj1.FrameRate;
    open(writerObj1);

    step = round(numel(ListFrames)/10);
    for ii=1:numel(ListFrames)
      i = ListFrames(ii);
      im=read(vid1,i);
      %im=imresize(im,0.5);
      %imc=imcrop(im,[60 60 300 300]);% The dimention of the new video
      if size(im,3) == 3
          if isempty(ListDim1)
              ListDim1 = 1:size(im,1);
          end
          if isempty(ListDim2)
              ListDim2 = 1:size(im,2);
          end
          imc = im(ListDim1,ListDim2,:);
          img=rgb2gray(imc);
      else
          img = im(ListDim1,ListDim2,:);
      end
      img = imresize(img,output_imsize);
      [a,b]=size(img);
      
      %imc=imresize(imc,[a,b]); % Do not resize
      
      writeVideo(writerObj1,img);  
      Intensity(ii) = sum(sum(img));
        %subplot(1,3,1)
        %imshow(im)
        %subplot(1,3,2)
        %imshow(imc)
        if rem(i,step)==0
            fprintf('.');
        end
    end
    d_Intensity = Intensity(2:end) - Intensity(1:end-1);
    fprintf('\n');
    close(writerObj1)
    
    fn_movie = fn;
    pn_movie = pn;
    save([pn_save ,'\' fn_base '_intensity.mat'],'fn_movie','pn_movie','FrameRate','Intensity','d_Intensity','ListDim1','ListDim2','ListFrames');
    
    h = figure('Name',[fn_base '_intensity_']);
    subplot(2,1,1);hold on;title('Intensity');
    plot(Intensity,'k');
    subplot(2,1,2);hold on;title('d Intensity resize abs');
    plot(d_Intensity,'r');
    saveas(h,[pn_save ,'\' fn(1:end-4) '_intensity.fig'],'fig');
    close(h);
    
end