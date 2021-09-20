function tdmapp(name, path)
%audio input
name = strcat(path, char(name));
[a Fs]=audioread(name(1,:));
b=audioread(name(2,:));
c=audioread(name(3,:));
d=audioread(name(4,:));

%% audio resize
[audio_size audio_data]=read_audio(a,b,c,d);
max_size=max(audio_size);
resized_audio_data= resize_audio(max_size,audio_data);
num_audio=length(resized_audio_data);

%% tdm
tdm_temp_1=zeros(1,num_audio*length(resized_audio_data{1}));
tdm_temp_2=zeros(1,num_audio*length(resized_audio_data{1}));

for ii=1:num_audio
    pp=resized_audio_data{ii};
    tdm_temp_1(ii:num_audio:end)=pp(:,1);
    tdm_temp_2(ii:num_audio:end)=pp(:,2);
    
end

%% Adding AWGN Noise
tdm_temp_1=awgn(tdm_temp_1,60);
tdm_temp_2=awgn(tdm_temp_2,60);
tdm=[tdm_temp_1' tdm_temp_2'];
%%
tdm=[tdm_temp_1' tdm_temp_2'];
% soundsc(tdm,num_audio*Fs); pause(5);


%% recover
for rr=1:num_audio
    temp_recov=tdm(rr:num_audio:end,:);
    recovered_tdm_audio{rr}= temp_recov;  
end

%% audio1
xt1=recovered_tdm_audio{1}(:,1);
[xr1] =reshape(xt1,1,[]);

xd1=wden(xr1,'heursure','h','sln',8,'sym8');
wind=blackman(16);
y1=conv(wind,xd1);
% soundsc(y1,Fs); pause(4);
% soundsc(a,Fs); pause(4);

%% audio2
xt2=recovered_tdm_audio{2}(:,1);
[xr2] =reshape(xt2,1,[]);

xd2=wden(xr2,'heursure','h','sln',8,'sym8');
wind=blackman(16);
y2=conv(wind,xd2);
% soundsc(y2,Fs); pause(4);

%% audio3
xt3=recovered_tdm_audio{3}(:,1);
[xr3] =reshape(xt3,1,[]);

xd3=wden(xr3,'heursure','h','sln',8,'sym8');
wind=blackman(16);
y3=conv(wind,xd3);
% soundsc(y3,Fs); pause(4);

%% audio4
xt4=recovered_tdm_audio{4}(:,1);
[xr4] =reshape(xt4,1,[]);

xd4=wden(xr4,'heursure','s','sln',12,'sym12');
wind=blackman(16);
y4=conv(wind,xd4);
% soundsc(y4,Fs); pause(4)

%% saving audio files
audiowrite('sender1.flac' , a, Fs);
audiowrite('sender2.flac' , b, Fs);
audiowrite('sender3.flac' , c, Fs);
audiowrite('sender4.flac' , d, Fs);

audiowrite('receiver1.flac' , y1/max(y1), Fs);
audiowrite('receiver2.flac' , y2/max(y2), Fs);
audiowrite('receiver3.flac' , y3/max(y3), Fs);
audiowrite('receiver4.flac' , y4/max(y4), Fs);

end
