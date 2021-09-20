%uniform quantization
function [y,q] = quan(x,level)

dif=(max(x)-min(x))/(level-1);
val=[min(x):dif:max(x)];

y=kron(val',ones(1,size(x,1)));
xp=x;

ref=repmat(xp',level,1);
x1=abs(y-ref);
[dis q]=min(x1);

end
