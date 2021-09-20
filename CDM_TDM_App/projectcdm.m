clc;
clear all;
close all;

level=128;
user=4;
Gp=64;

%% audio input

[x1,fm1]=audioread('1706128_1.flac');
[x2,fm2]=audioread('1706128_2.flac');
[x3,fm3]=audioread('1706128_15.flac');
[x4,fm4]=audioread('1706128_18.flac');

x1=x1(:,1);
x2=x2(:,1);
x3=x3(:,1);
x4=x4(:,1);

%% quantization

[y1 q1] = quan(x1,level);
[y2 q2] = quan(x2,level);
[y3 q3] = quan(x3,level);
[y4 q4] = quan(x4,level);

%% encoding
p1=q1-1;
p2=q2-1;
p3=q3-1;
p4=q4-1;

bits1=de2bi(p1,log2(level),'left-msb');
bits2=de2bi(p2,log2(level),'left-msb');
bits3=de2bi(p3,log2(level),'left-msb');
bits4=de2bi(p4,log2(level),'left-msb');

[m,n] = size(bits1);

[bitsc_1] =reshape(bits1',1,[]);
[bitsc_2] =reshape(bits2',1,[]);
[bitsc_3] =reshape(bits3',1,[]);
[bitsc_4] =reshape(bits4',1,[]);

bits=[bitsc_1; bitsc_2; bitsc_3; bitsc_4];
nbits=length(bits);

%% BPSK matrix and walsh code
bitsm=bits*2-1;

code=(1/sqrt(Gp))*hadamard(Gp);
code=code(1:user,:);
R=code*code';
y_tx=kron(bitsm,ones(1,Gp)).*repmat(code,1,nbits); %BPSK
y=sum(y_tx);


%% Adding AWGN Noise

yc=awgn(y,40);
w=reshape(yc,Gp,nbits);
w1=code*w;

%% ??????
bitsmr=sign(w1);
bitsr=(bitsmr+1)/2;

user1=bitsr(1,:);
bits_user1=reshape(user1,n,m);
bits_user1=bits_user1';

user2=bitsr(2,:);
bits_user2=reshape(user2,n,m);
bits_user2=bits_user2';

user3=bitsr(3,:);
bits_user3=reshape(user3,n,m);
bits_user3=bits_user3';

user4=bitsr(4,:);
bits_user4=reshape(user4,n,m);
bits_user4=bits_user4';

%% ---------- Multiplexed 


y5=sum(w1);

bitsmr1=sign(y5);
for i=1:length(bitsmr1)
    if bitsmr1(1,i)==0
        bitsr1(1,i)=0;
    else
        bitsr1(1,i)=(bitsmr1(1,i)+1)/2;
    end
end
bits_user5=reshape(bitsr1,n,m);
bits_user5=bits_user5';

xr=bi2de(bits_user5,'left-msb');
xrt=xr+1;
xd=wden(xrt,'heursure','h','mln',level,'sym8');
soundsc(xrt,fm1); pause(5);



%% ------------  USER 1

xr1=bi2de(bits_user1,'left-msb');
xrt1=xr1+1;
soundsc(x1,fm1); pause(4);
% xd1=wden(xrt1,'sqtwolog','h','sln',128,'sym8');
% soundsc(xd1,fm1);pause(4)
[b1,a1] = butter(12,0.2,'low');           % IIR filter design
y1 = filtfilt(b1,a1,xrt1);                 % zero-phase filtering
soundsc(y1,fm1); pause(4);

%% ------------  USER 2

xr2=bi2de(bits_user2,'left-msb');
xrt2=xr2+1;
soundsc(x2,fm2);pause(4);
% xd2=wden(xrt2,'sqtwolog','h','sln',128,'sym8');
% soundsc(xd2,fm2);pause(4)
[b2,a2] = butter(12,0.25,'low');           % IIR filter design
y2 = filtfilt(b2,a2,xrt2);                 % zero-phase filtering
soundsc(y2,fm2); pause(4);

%% ------------  USER 3

xr3=bi2de(bits_user3,'left-msb');
xrt3=xr3+1;
xd3=wden(xrt3,'heursure','h','mln',level,'sym8');
soundsc(x3,fm3);pause(4)
soundsc(xd3,fm3);pause(4)
[b3,a3] = butter(12,0.2,'low');           % IIR filter design
y3 = filtfilt(b3,a3,xrt3);                % zero-phase filtering
soundsc(y3,fm3);pause(4)

%% -------------- USER 4
xr4=bi2de(bits_user4,'left-msb');
xrt4=xr4+1;
xd4=wden(xrt4,'sqtwolog','h','mln',level,'sym8');

soundsc(x4,fm4) ; pause(4);
soundsc(xd4,fm4) ; pause(4);
[b4,a4] = butter(12,0.2,'low');           % IIR filter design
y4 = filtfilt(b4,a4,xrt4);                % zero-phase filtering
soundsc(y4,fm4);

