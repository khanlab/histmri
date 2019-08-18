function init_openslide

%now uses openslide to query and read the image - need to load appropriate 
script_folder=fileparts(mfilename('fullpath'));

%get path to libraries based on computer architecture
lib_folder=fullfile(sprintf('%s/../openslide-3.4.1/%s',script_folder,computer('arch')));

if (~exist(lib_folder))
    disp('openslide binaries at %s do not exist! quitting!',lib_folder);
    return
end

%add to matlab path
addpath(genpath(lib_folder));

%load library
openslide_load_library;


end
