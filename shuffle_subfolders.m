%shuffle_subfolders

clear;
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
pn_def = uigetdir(pn_def,'select grandparent folder');
save([pn_main '\' fn_datalocation],'pn_def');

extension = input('Type avi or tif \n','s');
yn_random = input('yn randomize \n','s');
ListChar = input('Type vector of last pn to add filenames\n');
%------------------------------------------------------------

pn_grandparent = pn_def;
[void, pn_grandparent_last] = fileparts(pn_grandparent);
ListMov = dir(fullfile(pn_grandparent, '*', ['*.', extension]));
ListPn = cellstr(vertcat(ListMov.folder));
UniquePn = unique(ListPn);

pn_grandparent_last_copy = [pn_grandparent_last,'_copy'];
for id_pn = 1:numel(UniquePn)
    start = strfind(UniquePn{id_pn},pn_grandparent_last);
    stop = max(strfind(UniquePn{id_pn},'\'));
    UniquePnCopy{id_pn} = [UniquePn{id_pn}(1:start-1), pn_grandparent_last_copy , UniquePn{id_pn}(stop:end)];
end
for id_mov = 1:numel(ListMov)
    fn_full_sorce = [ListMov(id_mov).folder '\' ListMov(id_mov).name];
    [void, pn_last] = fileparts(ListMov(id_mov).folder);
    if yn_random == 'y'
        rand_number = randi(numel(UniquePn));
        pn_target = UniquePnCopy{rand_number};
    else
        [pn_temp, void] = fileparts(UniquePnCopy{1});% 適当に１から取得。
        pn_target = [pn_temp, '\' pn_last];
    end
    if ~exist(pn_target,'dir')
        mkdir(pn_target);
    end
    fn_full_target = [pn_target ,'\' pn_last(ListChar) '_' ListMov(id_mov).name(1:end-4), ListMov(id_mov).name(end-3:end)];
    %fn_full_target = [pn_target ,'\' ListMov(id_mov).name(1:end-4), ListMov(id_mov).name(end-3:end)];
    copyfile(fn_full_sorce,fn_full_target)
end