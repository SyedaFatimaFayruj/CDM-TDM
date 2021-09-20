function [audio_size audio_data]=read_audio(varargin)
% reads audio and collect data from it
audio_size=[];
for i=1:nargin
    p=varargin{i};
    audio_size=[audio_size length(p)];
    audio_data{i}=p;
end
    

end

