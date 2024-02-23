function [fn_out, FrameRate] = crop_circle(fn,pn,varargin)

    pn_save = 'crop_circle';%default
    for ii = 1:nargin-2
        if strcmp(varargin{ii}, 'pn_save')
            pn_save = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'radius')
            radius = varargin{ii+1};
        end 
        if strcmp(varargin{ii}, 'angle')
            angle = varargin{ii+1};
        end 
    end
    pn_save = [pn '\' pn_save];%default

    if ~exist(pn_save,'dir')
        mkdir(pn_save);
    end
    
    vid1=VideoReader([pn ,'\' fn]);
    n=vid1.NumberOfFrames;
    ListFrames = 1:n;
    fprintf('%s: %d Frames ',fn, numel(ListFrames));
    %-----------------------
    im=read(vid1,1);
    
    fn_base = [fn(1:end-4) '_circle' num2str(ListFrames(1))];
    fn_out = [fn_base '.avi'];

    writerObj1 = VideoWriter([pn_save '\' fn_out]);
    writerObj1.FrameRate = vid1.FrameRate;
    FrameRate = writerObj1.FrameRate;
    open(writerObj1);

    step = round(numel(ListFrames)/10);

    
    for ii=1:numel(ListFrames)
      i = ListFrames(ii);
      im=read(vid1,i);

      if ii == 1
        [rows, columns, numColorChannels] = size(im);
        Y = round(rows*(0.5+radius*cos(0:pi/100:2*pi)));
        X = round(columns*(0.5+radius*sin(0:pi/100:2*pi)));
        mask = uint8(repmat(poly2mask(X, Y, rows, columns),1,1,size(im,3)));
      end

      img_temp = im.*mask;
      targetSize = [rows columns];
      r = centerCropWindow2d([size(img_temp,1),size(img_temp,2),size(img_temp,3)],targetSize);
      J = imcrop(img_temp,r); 
      side = max(rows,columns);
      K = imresize(J,[side,side]);
      img = imrotate(K, angle,'crop');
      writeVideo(writerObj1,img);  

        if rem(i,step)==0
            fprintf('.');
        end
    end

    fprintf('\n');
    close(writerObj1)

end