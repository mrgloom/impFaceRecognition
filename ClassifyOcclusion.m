function [cClass, SCI, Outxp, OutImg] = ClassifyOcclusion(y, Reconstructed)
    global A;
    global Class;
	global TrainSize;
    global TestImageSize;
    
	RejectThreshold = 0;
    %global Test;
    
    lambda = 1000;
    %y = A*x;
    % initial guess = min energy    
    %y = zeros(size(sample,1));
    %for i =1:size(sample,1)
        %y(i,1) = sample(i,1);
    %end
    %B = A;
    %y = A'*y;
    %A = A'*A;    
    %x0 = A'*y;
    % solve the LP    
    B = [A eye(size(A,1))];
    tic
    %xp = l1eq_pd(x0, A, [], y, 1e-3);
    %xp = LassoConstrained(A,y,lambda,'mode',2);
    %[xp wp iteration] = LassoBlockCoordinate(A,y,lambda);
    %[xp wp iteration] = LassoBlockCoordinate(B,y,lambda);
    %[xp it] = SolveLasso(B, y, size(B,2), 'lars');
    [xp it] = SolveOMP(B, y, size(B,2));
    %[xp it] = LassoNonNegativeSquared(B,y,lambda);
    %[xp wp iteration] = LassoBlockCoordinateOri(B,y,lambda);
    %[xp it] = LassoGaussSeidel(B,y,lambda) 
%     sparseSupport = randperm(size(B,2));
%     x0=zeros(size(B,2),1);
%     k = ceil(0.1*size(B,2));
%     x0(sparseSupport(1:k))=randn(1,k);
%     x0 = x0 / norm(x0);            
%     [xp, it] = SolveHomotopyB(B, y, ...
%                         'maxIteration', 1000,...
%                         'isNonnegative', false, ...                                                
%                         'lambda', 5e-7, ...
%                         'tolerance', 5e-7);
%     global InvX_X;    
%     global FirstRidgeRegression;
%     if (FirstRidgeRegression == 1)
%         tic
%         XX = B' * B;            
%         InvX_X = inv(XX);        
%         toc
%         FirstRidgeRegression = 0;    
%         clear XX;
%     else
%     end    
% 
     %x0 = InvX_X*(B'*y);
     %x0 = (B'*B )\(B'*y);
     %xp = l1eq_pd(x0, B, [], y, 5e-2, lambda);
    toc
    
    tic
    Outxp = xp;
    e1=xp(size(A,2) + 1:size(xp,1),1);
    xp = xp(1: size(A,2));
    vMin = -1;
    iMin = 0;
    Next = 0;
	MaxVector = 0;    
    yR = y - e1;
    for i = 1: size(Class,2) % so lop
        val = 0;
        %for j = 1: Class(1,i) % so phan tu cua lop i
            %val = abs(val + xp(Next + j,1));
        %end
        %CVector = GetClassVector(Next+1,Next+ Class(1,i), xp);
		CVector = GetClassVector((i-1)*TrainSize+1, i*TrainSize, xp);
        y0 = A * CVector;
        val = abs(pdist([yR y0]'));
        if(vMin <0 | vMin>val)
            vMin = val;
            iMin = i;			
        end
		%if(sum(abs(MaxVector(:,1))) < sum(abs(CVector(:,1))))
			%MaxVector = CVector;
		%end
        %Next = Next+ Class(1,i);
    end
    toc
	%compute SCI
	SCI = (size(Class,2) * sum(abs(MaxVector(:,1))) / sum(abs(xp(:,1))) - 1) / (size(Class,2) - 1);
	if(SCI < RejectThreshold)
		cClass = -1;
	else
		cClass = iMin;
    end	
    cClass = iMin;
    if(exist('Reconstructed') > 0)
        if(Reconstructed == 1)
            %x0  = GetClassVector((cClass-1)*TrainSize+1, cClass*TrainSize, xp);
            %y0 = A * x0;            
            OutImg = ReshapeImage((B*Outxp-e1)*255, TestImageSize(1), TestImageSize(2));
        end        
    end
    %histmax(xp, size(A,2));
end

function [CVector] = GetClassVector(leftIndex, rightIndex, orgVector)
%     scale = 0;
%     first = 1;
%     max = 0;    
%     minVal = min(orgVector(:,1));
%     if(minVal == 0)
%         minVal = 1e-8;
%     end
%     for j = 1: size(orgVector,1)
%             if(j<leftIndex || j>rightIndex)
%                 if(first)
%                     first = 0;
%                     max = abs(orgVector(j,1));
%                 elseif(max < orgVector(j,1))
%                     max = abs(orgVector(j,1));
%                 end
%             end
%     end    
%     scale = max / minVal;
    CVector = zeros(size(orgVector,1), 1);
    CVector(leftIndex:rightIndex, 1) = orgVector(leftIndex:rightIndex, 1);
end