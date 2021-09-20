function cdmapp(name,path)
level=128;
user=4;
Gp=64;

%% audio input
name = strcat(path, char(name));
[x1,fm1]=audioread(name(1,:));
[x2,fm2]=audioread(name(2,:));
[x3,fm3]=audioread(name(3,:));
[x4,fm4]=audioread(name(4,:));

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

yc=awgn(y,60);
w=reshape(yc,Gp,nbits);


%% Decoding

w1=code*w;
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



%% ------------  USER 1

xr1=bi2de(bits_user1,'left-msb');
xrt1=xr1+5;
%soundsc(x1,fm1); pause(4);
y1=wden(xrt1,'sqtwolog','h','sln',128,'sym8');
%soundsc(y1,fm1); pause(4);

%% ------------  USER 2

xr2=bi2de(bits_user2,'left-msb');
xrt2=xr2+5;
%soundsc(x2,fm2);pause(4);
y2=wden(xrt2,'sqtwolog','h','sln',128,'sym8');
%soundsc(y2,fm2);pause(4)

%% ------------  USER 3

xr3=bi2de(bits_user3,'left-msb');
xrt3=xr3+5;
%soundsc(x3,fm3);pause(4);
y3 =wden(xrt3,'sqtwolog','h','sln',128,'sym8');
%soundsc(y3,fm3);pause(4)

%% -------------- USER 4
xr4=bi2de(bits_user4,'left-msb');
xrt4=xr4+5;
%soundsc(x4,fm4); pause(4);
y4=wden(xrt4,'sqtwolog','h','mln',level,'sym8');
%soundsc(y4,fm4); pause(4);

%% Calculating SNR

snr1 = 10*log(meansqr(y1/max(abs(y1)))/meansqr((y1/max(abs(y1)))-(x1/max(abs(x1)))))
snr2 = 10*log(meansqr(y2/max(abs(y2)))/meansqr((y2/max(abs(y2)))-(x2/max(abs(x2)))))
snr3 = 10*log(meansqr(y3/max(abs(y3)))/meansqr((y3/max(abs(y3)))-(x3/max(abs(x3)))))
snr4 = 10*log(meansqr(y4/max(abs(y4)))/meansqr((y4/max(abs(y4)))-(x4/max(abs(x4)))))


%% -------------- Saving Audio
audiowrite('sender1.flac' , x1, fm1);
audiowrite('sender2.flac' , x2, fm2);
audiowrite('sender3.flac' , x3, fm3);
audiowrite('sender4.flac' , x4, fm4);

audiowrite('receiver1.flac' , y1/max(abs(y1)), fm1);
audiowrite('receiver2.flac' , y2/max(abs(y2)), fm2);
audiowrite('receiver3.flac' , y3/max(abs(y3)), fm3);
audiowrite('receiver4.flac' , y4/max(abs(y4)), fm4);
end