function resized_audio_data= resize_audio(max_size,audio_data)
% this will resize all the audio files

for i=1:length(audio_data)
    if length(audio_data{i})~=max_size
        temp=max_size-length(audio_data{i});
        zero_to_add=zeros(temp,2);
        audio_data{i}=[audio_data{i};zero_to_add];
        resized_audio_data{i}=audio_data{i};
    else resized_audio_data{i}=audio_data{i};
    end
    
end
end

