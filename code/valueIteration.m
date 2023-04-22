
clear
close all
% Define rewards:
R = zeros(64,1);
R(64) = 100;
R([2,12,14,15, 18,28,30,34,36,37,38,40,50,52,55,58,63]) = -100;

% Define actions
A = zeros(64,5);
for i = 1:64
    x = mod((i-1),8)+1;
    y = ceil(i/8);
        % right
    if x == 8
        A(i,1) = i;
    else
        x1 = x+1;
        y1 = y;
        A(i,1) = 8*(y1-1)+x1;
    end
        % up
    if y == 8
        A(i,2) = i;
    else
        x1 = x;
        y1 = y+1;
        A(i,2) = 8*(y1-1)+x1;
    end
        % left
    if x == 1
        A(i,3) = i;
    else
        x1 = x-1;
        y1 = y;
        A(i,3) = 8*(y1-1)+x1;
    end
        % down
    if y == 1
        A(i,4) = i;
    else
        x1 = x;
        y1 = y-1;
        A(i,4) = 8*(y1-1)+x1;
    end
        % stay
    A(i,5) = i;
end

% Define probabilities
Pr = zeros(64,64,5);
for s = 1:64
    for i = 1:5
        for j = 1:5
            if i==j
                Pr(A(s,j),s,i) = 0.8;
            elseif i ~= 5 && j == mod(i+5,4)+1
                Pr(A(s,j),s,i) = 0;
            else
                Pr(A(s,j),s,i) = 0.05;
            end
        end
        Pr(:,s,i) = Pr(:,s,i)/sum(Pr(:,s,i));
    end
end

% Value iteration
mm = 30;
N = 64;
gamma = 0.95;
V = zeros(N,1);
OP = zeros(N,1);
e = inf;
while e > 1e-14
    V1 = zeros(N,1);
    for j = 1:N
        [V1(j),OP(j)] = max([R(j)+gamma*Pr(:,j,1)'*V(:);
            R(j)+gamma*Pr(:,j,2)'*V(:);
            R(j)+gamma*Pr(:,j,3)'*V(:);
            R(j)+gamma*Pr(:,j,4)'*V(:);
            R(j)+gamma*Pr(:,j,5)'*V(:)]);
    end
    e = max(V1-V);
    V = V1;
end

x = zeros(64,1);
y = zeros(64,1);
u = zeros(64,1);
v = zeros(64,1);
for i = 1:N
    x(i) = mod((i-1),8)+1;
    y(i) = ceil(i/8);
    j = A(i,OP(i));
    u(i) = mod((j-1),8)+1-x(i);
    v(i) = ceil(j/8)-y(i);
end
quiver(x-0.5,y-0.5,u,v)
grid on

