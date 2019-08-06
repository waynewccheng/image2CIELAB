% generate the histogram of dE of 1000 image-pairs in two folders

%folder1 = 'input/original';
%folder2 = 'input/Macenko';

function my_all (folder1, folder2)

file_list1 = getInputFileList(folder1);
file_list2 = getInputFileList(folder2);

n = size(file_list1,2)
data = zeros(n,1);

for i = 1:n
    
    fn_method1 = sprintf('%s/%s',folder1,file_list1{1,i});
    fn_method2 = sprintf('%s/%s',folder2,file_list2{1,i});
    
    de = my1(fn_method1,fn_method2);
    
    data(i) = de;
end

% plot
figure('units','normalized','outerposition',[0 0 1 1])

histogram(data)
xlabel('dE')
ylabel('Count')

fn1 = folder1(strfind(folder1,'/')+1:end);
fn2 = folder2(strfind(folder2,'/')+1:end);

saveas(gcf,sprintf('%s-%s.tif',fn1,fn2))

save(sprintf('%s-%s.mat',fn1,fn2),'data')

return

end

    function input_file_list = getInputFileList (subfoldername)
        % create a list based on the file in the folder
        % or just enter the list
        %    [3 24 34 39 40 43 46 48 51 52 56 57 59 60 68 71 77 85 88 91 93 95 97 99 310 316 336 337 342 347 356 360 389 398]
        dirdata = dir(subfoldername);                            % the subfolder
        input_file_list = {};
        k = 0;
        for i = 1:size(dirdata,1)                          % for each file
            filename = dirdata(i).name;                    % get the filename part
            if strfind(filename,'_') ~= 0            % if it is Filter_XX
                k = k + 1;
                input_file_list{k} = filename;
            end
        end
    end