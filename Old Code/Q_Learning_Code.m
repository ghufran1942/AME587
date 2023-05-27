
clc;
clear;

Q=rand(30,30,3);
% save("Q_Random.mat","Q")
% Q = importdata("Q_table.mat");

% Initializing constants
pfwd=0.7;
alp=0.31;
gam=0.1;
N=540;
kMax=1000;

% Allocating array sizes
r = zeros(1, N);
xold=zeros(kMax,N);
x=zeros(1,N);
%for xT = 15:16
    xT = 15;
    for k=1:kMax
    
        x_ini=randi(30)
        
        
    
        eps0=1;
        eps=eps0;
    
    
        x(1)=x_ini;
    
        for i=1:N
    
            % chose an action from state x(i)
    
            [~,a] =  max(Q(xT,x(i),:));
    
            c=rand;
            if c>eps, a=a; else, a=randi(3);end
    
            eps=eps+(1-eps0)/N;
    
            x(i+1)=x(i)+(a-2)*randsrc(1,1,[1 -1;pfwd  1-pfwd]) ; % motion of human based on action
    
                if x(i+1)>=20, x(i+1)=20;end
    
            if x(i+1)<=1, x(i+1)=1;end
    
        
    
            [~,a_next] = max(Q(xT,x(i+1),:));  % get future action
    
            if abs(x(i+1)-xT)< abs(x(i)-xT)
                r(i)=1;
            elseif abs(x(i+1)-xT) < 1
                r(i)=2;
                a = 2;
    
            else 
                r(i)=-1; 
            end
    
            Q(xT,x(i),a)=Q(xT,x(i),a)+alp*(r(i)-gam*Q(xT,x(i+1),a_next)-Q(xT,x(i),a));
    
            xold(k,i)=x(i);
    
        end
        alp = alp + (1-eps);
        
    save(sprintf('data/Q_table_after_eps_%d',k),'Q');
    end
%end


x(1)=randi(30); %randi([min(xold) max(xold)]);

 %{

for i=1:N,

    % chose an action from state x(i)

    [~,a] = max(Q(x(i),:));

    x(i+1)=x(i)+(a-2)*randsrc(1,1,[1 -1;pfwd  1-pfwd]); % motion of human based on action

    if x(i+1)>=20, x(i+1)=20;end

    if x(i+1)<=1, x(i+1)=1;end

    [~,a_next] = max(Q(x(i+1),:));  % get future action

    if abs(x(i+1)-xT)< abs(x(i)-xT), r(i)=0;

    else r(i)=-1; end

    Q(x(i),a)=Q(x(i),a)+alp*(r(i)-gam*Q(x(i+1),a_next)-Q(x(i),a));

end
 %}


%figure; hold

%stairs(xold,'b');stairs(x);legend('Training Data','Trained Sys. w New IC-s.');shg

 

figure

hold

for k=1:10,plot(xold(k,:));end

plot(x,'r')
xlim([0 21])

legend({'Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data', 'Trained'})

xlabel('Time, t');ylabel('State,s(t)')

shg

figure

bar3(Q+1);shg
